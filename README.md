# GenGraph

GenGraph provides a way to build graph and tree data structures using GenServer-based nodes. Each node in a GenGraph is a GenServer process that can maintain edges to other nodes, enabling concurrent operations and automatic cleanup when processes terminate.

## Features

- **Process-based nodes**: Each node is a GenServer, enabling concurrent operations
- **Automatic cleanup**: Edges are automatically removed when connected processes die
- **Flexible relationships**: Support for weighted and bidirectional edges
- **Tree structures**: Specialized tree nodes with parent-child relationships and cycle prevention
- **GenObject integration**: Built on top of GenObject for enhanced process management
- **Monitor-based**: Uses process monitoring for robust edge management

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `gen_graph` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_graph, "~> 0.1.0"}
  ]
end
```

## Quick Start

### Basic Graph Usage

```elixir
# Define a node module
defmodule MyNode do
  use GenGraph.Node, [
    data: nil,
    name: ""
  ]
end

# Create nodes
node1 = MyNode.new(data: "first", name: "node1")
node2 = MyNode.new(data: "second", name: "node2")
node3 = MyNode.new(data: "third", name: "node3")

# Add edges between nodes
node1 = MyNode.add_edge(node1, node2)
node1 = MyNode.add_edge(node1, node3, weight: 5)

# Create bidirectional edges
node2 = MyNode.add_edge(node2, node3, bidirectional: true)

# Check edges
IO.inspect(node1.edges)  # [{node2.pid, 0}, {node3.pid, 5}]
IO.inspect(node2.edges)  # [{node3.pid, 0}]
IO.inspect(node3.edges)  # [{node2.pid, 0}]
```

### Tree Usage

```elixir
# Define a tree node module
defmodule TreeNode do
  use GenGraph.Tree, [
    name: "",
    data: nil
  ]
end

# Create tree structure
root = TreeNode.new(name: "root")
child1 = TreeNode.new(name: "child1")
child2 = TreeNode.new(name: "child2")
grandchild = TreeNode.new(name: "grandchild")

# Build tree relationships
root = TreeNode.add_child(root, child1)
root = TreeNode.add_child(root, child2)
child1 = TreeNode.add_child(child1, grandchild)

# Check tree structure
IO.inspect(root.child_nodes)     # [child1.pid, child2.pid]
IO.inspect(child1.child_nodes)   # [grandchild.pid]
IO.inspect(TreeNode.get(grandchild, :parent_pid)) # child1.pid

# Cycle prevention - this will return :error
TreeNode.add_child(grandchild, root)  # :error
```

## Core Concepts

### Nodes

Every node in GenGraph is a GenServer process created using GenObject. Nodes maintain:

- **edges**: A list of `{pid, weight}` tuples representing outgoing connections
- **refs**: A map of monitor references to connected PIDs for automatic cleanup
- **Custom fields**: Any additional data defined when using the module

### Edges

Edges represent connections between nodes and support:

- **Weights**: Numeric values associated with edges (default: 0)
- **Bidirectional**: Edges can be created in both directions simultaneously
- **Automatic cleanup**: Edges are removed when target processes terminate

### Process Monitoring

GenGraph uses Erlang's process monitoring to ensure data consistency:

- When an edge is created, the source node monitors the target node
- If a target node process dies, the edge is automatically removed
- Monitor references are properly cleaned up

## API Reference

### GenGraph.Node

#### `add_edge(from, to, opts \\ [])`

Adds an edge between two nodes with optional configuration.

**Options:**
- `:weight` - Numeric weight for the edge (default: 0)
- `:bidirectional` - Create edges in both directions (default: false)

**Examples:**
```elixir
# Simple edge
node1 = MyNode.add_edge(node1, node2)

# Weighted edge
node1 = MyNode.add_edge(node1, node2, weight: 5)

# Bidirectional edge
node1 = MyNode.add_edge(node1, node2, bidirectional: true)
```

#### `add_edge!(from, to, opts \\ [])`

Asynchronously adds an edge using GenServer.cast for better performance.

#### `remove_edge(from, to, opts \\ [])`

Removes an edge between two nodes.

**Options:**
- `:weight` - Specific weight of edge to remove (default: 0)
- `:bidirectional` - Remove edges in both directions (default: false)

#### `remove_edge!(from, to, opts \\ [])`

Asynchronously removes an edge using GenServer.cast.

### GenGraph.Tree

Tree nodes inherit all GenGraph.Node functionality plus:

#### `add_child(parent, child, opts \\ [])`

Adds a child node to a parent with cycle detection.

**Returns:** Updated parent struct or `:error` if operation would create a cycle.

#### `add_child!(parent, child, opts \\ [])`

Asynchronously adds a child (no cycle detection).

#### `remove_child(parent, child, opts \\ [])`

Removes a child node from a parent.

#### `remove_child!(parent, child, opts \\ [])`

Asynchronously removes a child node.

### GenServer Callbacks

Both `GenGraph.Node` and `GenGraph.Tree` implement GenServer callbacks that handle the internal messaging for edge management:

#### GenGraph.Node Callbacks

- `handle_call({:add_edge, node_pid, opts}, from, object)` - Handles synchronous edge addition
- `handle_call({:remove_edge, node_pid, opts}, from, object)` - Handles synchronous edge removal
- `handle_cast({:add_edge, node_pid, opts}, object)` - Handles asynchronous edge addition
- `handle_cast({:remove_edge, node_pid, opts}, object)` - Handles asynchronous edge removal
- `handle_info({:DOWN, ref, :process, pid, reason}, object)` - Handles process termination cleanup

#### GenGraph.Tree Callbacks

Tree nodes extend the Node callbacks with additional behavior:

- `handle_call({:add_edge, node_pid, opts}, from, object)` - Adds cycle detection and parent_pid management
- `handle_call({:remove_edge, node_pid, opts}, from, object)` - Clears parent_pid on removed children
- `handle_cast` variants - Similar extensions but without cycle detection
- `handle_info({:DOWN, ...}, object)` - Synchronizes child_nodes list after cleanup

#### Private Helper Functions

- `do_add_edge/3` - Internal function to add edges and monitor references
- `do_remove_edge/3` - Internal function to remove edges and clean up monitors
- `do_mirror_edges/2` (Tree only) - Synchronizes child_nodes with edges list
- `is_ancestor?/2` (Tree only) - Recursively checks for circular references

## Advanced Features

### Cycle Prevention

Tree nodes automatically prevent circular references:

```elixir
parent = TreeNode.new()
child = TreeNode.new()
grandchild = TreeNode.new()

parent = TreeNode.add_child(parent, child)
child = TreeNode.add_child(child, grandchild)

# This will return :error due to cycle detection
TreeNode.add_child(grandchild, parent)  # :error
```

### Automatic Cleanup

When a node process terminates, all edges pointing to it are automatically cleaned up:

```elixir
node1 = MyNode.new()
node2 = MyNode.new()

node1 = MyNode.add_edge(node1, node2)
IO.inspect(length(node1.edges))  # 1

# Kill node2
Process.exit(node2.pid, :kill)
:timer.sleep(10)

node1 = MyNode.get(node1)
IO.inspect(length(node1.edges))  # 0 - edge automatically removed
```

### Working with PIDs and Structs

All functions accept either PIDs or GenObject structs:

```elixir
# These are equivalent
MyNode.add_edge(node1, node2)
MyNode.add_edge(node1.pid, node2.pid)
MyNode.add_edge(node1, node2.pid)
MyNode.add_edge(node1.pid, node2)
```

## GenObject Integration

GenGraph is built on top of [GenObject](https://hex.pm/packages/gen_object), which provides:

- Enhanced GenServer functionality
- Struct-based process interaction
- Automatic PID management
- Built-in getter/setter methods

Each node automatically gets GenObject methods like:
- `new/1` - Create a new node process
- `get/1` - Retrieve current node state
- `get/2` - Get specific field value
- `put/3` - Set field value

## Testing

Run the test suite:

```bash
mix test
```

The test suite includes comprehensive tests for:
- Basic edge operations
- Bidirectional edges
- Weighted edges
- Automatic cleanup on process termination
- Tree operations and cycle prevention
- Parent-child relationship management

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## Acknowledgments

- Built by [DockYard](https://dockyard.com/phoenix-consulting)
- Uses [GenObject](https://hex.pm/packages/gen_object) for enhanced process management
- Inspired by graph theory and actor model patterns

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found at <https://hexdocs.pm/gen_graph>.
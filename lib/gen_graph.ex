defmodule GenGraph do
  @moduledoc """
  GenGraph provides a way to build graph and tree data structures using GenServer-based nodes.

  Each node in a GenGraph is a GenServer process that can maintain edges to other nodes.
  Nodes automatically monitor connected nodes and clean up edges when processes terminate.

  ## Features

  - **Process-based nodes**: Each node is a GenServer, enabling concurrent operations
  - **Automatic cleanup**: Edges are automatically removed when connected processes die
  - **Flexible relationships**: Support for weighted and bidirectional edges
  - **Tree structures**: Specialized tree nodes with parent-child relationships and cycle prevention
  - **GenObject integration**: Built on top of GenObject for enhanced process management

  ## Basic Usage

      # Create nodes using modules that `use GenGraph.Node`
      defmodule MyNode do
        use GenGraph.Node, [data: nil]
      end

      # Create and connect nodes
      node1 = MyNode.new(data: "first")
      node2 = MyNode.new(data: "second")

      # Add an edge from node1 to node2
      node1 = MyNode.add_edge(node1, node2)

  ## Tree Usage

      # Create tree nodes using modules that `use GenGraph.Tree`
      defmodule TreeNode do
        use GenGraph.Tree, [name: ""]
      end

      parent = TreeNode.new(name: "parent")
      child = TreeNode.new(name: "child")

      # Add child relationship
      parent = TreeNode.add_child(parent, child)
  """
end

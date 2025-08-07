defmodule GenGraph.Node do
  @moduledoc """
  GenGraph.Node provides the core functionality for creating graph nodes using GenServer processes.

  When a module uses GenGraph.Node, it becomes a GenServer that can maintain edges to other nodes.
  Each node automatically monitors connected nodes and removes edges when those processes terminate.

  ## Node State

  Each node maintains:
  - `refs`: A map of monitor references to connected node PIDs
  - `edges`: A list of `{pid, weight}` tuples representing outgoing edges
  - Additional custom fields defined when using the module

  ## Usage

      defmodule MyNode do
        use GenGraph.Node, [
          data: nil,
          custom_field: "default"
        ]
      end

      # Create nodes
      node1 = MyNode.new(data: "first node")
      node2 = MyNode.new(data: "second node")

      # Add edges
      node1 = MyNode.add_edge(node1, node2)
      node1 = MyNode.add_edge(node1, node2, weight: 5, bidirectional: true)

  ## Edge Options

  - `weight`: Numeric weight for the edge (default: 0)
  - `bidirectional`: If true, creates edges in both directions (default: false)

  ## Automatic Cleanup

  When a connected node process terminates, the edge is automatically removed from
  all connected nodes through process monitoring.
  """

  import GenGraph, only: [
    to_pid: 1,
    is_node_or_pid: 1
  ]

  use GenObject, [
    refs: %{},
    edges: []
  ]

  @doc """
  Adds an edge between two nodes with optional configuration.

  This function creates a monitored connection from the `from` node to the `to` node.
  If the `to` node process terminates, the edge will be automatically removed.

  ## Parameters

  - `from`: Source node (PID or GenObject struct)
  - `to`: Target node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Numeric weight for the edge (default: 0)
  - `:bidirectional` - Create edges in both directions (default: false)

  ## Examples

      # Simple edge
      node1 = MyNode.add_edge(node1, node2)

      # Weighted edge
      node1 = MyNode.add_edge(node1, node2, weight: 5)

      # Bidirectional edge
      node1 = MyNode.add_edge(node1, node2, bidirectional: true)

  ## Returns

  Returns the updated `from` node struct.
  """
  def add_edge(from, to, opts \\ []) when is_node_or_pid(from) and is_node_or_pid(to) and is_list(opts) do
    from = to_pid(from)
    to = to_pid(to)

    if Keyword.get(opts, :bidirectional, false) do
      GenServer.call(to, {:add_edge, from, weight: Keyword.get(opts, :weight, 0)})
    end
    GenServer.call(from, {:add_edge, to, weight: Keyword.get(opts, :weight, 0)})
  end
  defoverridable add_edge: 2, add_edge: 3

  @doc """
  Asynchronously adds an edge between two nodes using GenServer.cast.

  Similar to `add_edge/3` but uses asynchronous messaging for better performance
  when you don't need to wait for confirmation of the edge creation.

  ## Parameters

  - `from`: Source node (PID or GenObject struct)
  - `to`: Target node (PID or GenObject struct) 
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Numeric weight for the edge (default: 0)
  - `:bidirectional` - Create edges in both directions (default: false)

  ## Examples

      # Async edge creation
      MyNode.add_edge!(node1, node2)
      MyNode.add_edge!(node1, node2, weight: 3, bidirectional: true)

  ## Returns

  Returns `:ok` immediately without waiting for completion.
  """
  def add_edge!(from, to, opts \\ []) when is_node_or_pid(from) and is_node_or_pid(to) and is_list(opts) do
    from = to_pid(from)
    to = to_pid(to)

    if Keyword.get(opts, :bidirectional, false) do
      GenServer.cast(to, {:add_edge, from, weight: Keyword.get(opts, :weight, 0)})
    end
    GenServer.cast(from, {:add_edge, to, weight: Keyword.get(opts, :weight, 0)})
  end
  defoverridable add_edge!: 2, add_edge!: 3

  @doc """
  Removes an edge between two nodes.

  This function removes the monitored connection from the `from` node to the `to` node.
  The monitor reference is cleaned up and the edge is removed from the edges list.

  ## Parameters

  - `from`: Source node (PID or GenObject struct)
  - `to`: Target node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Specific weight of edge to remove (default: 0)
  - `:bidirectional` - Remove edges in both directions (default: false)

  ## Examples

      # Remove simple edge
      node1 = MyNode.remove_edge(node1, node2)

      # Remove bidirectional edges
      node1 = MyNode.remove_edge(node1, node2, bidirectional: true)

  ## Returns

  Returns the updated `from` node struct.
  """
  def remove_edge(from, to, opts \\ []) when is_node_or_pid(from) and is_node_or_pid(to) and is_list(opts) do
    from = to_pid(from)
    to = to_pid(to)
    weight = Keyword.get(opts, :weight, 0)

    if Keyword.get(opts, :bidirectional, false) do
      GenServer.call(to, {:remove_edge, from, weight: weight})
    end
    GenServer.call(from, {:remove_edge, to, weight: weight})
  end
  defoverridable remove_edge: 2, remove_edge: 3

  @doc """
  Asynchronously removes an edge between two nodes using GenServer.cast.

  Similar to `remove_edge/3` but uses asynchronous messaging for better performance
  when you don't need to wait for confirmation of the edge removal.

  ## Parameters

  - `from`: Source node (PID or GenObject struct)
  - `to`: Target node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Specific weight of edge to remove (default: 0)
  - `:bidirectional` - Remove edges in both directions (default: false)

  ## Examples

      # Async edge removal
      MyNode.remove_edge!(node1, node2)
      MyNode.remove_edge!(node1, node2, bidirectional: true)

  ## Returns

  Returns `:ok` immediately without waiting for completion.
  """
  def remove_edge!(from, to, opts \\ []) when is_node_or_pid(from) and is_node_or_pid(to) and is_list(opts) do
    from = to_pid(from)
    to = to_pid(to)

    if Keyword.get(opts, :bidirectional, false) do
      GenServer.cast(to, {:remove_edge, from, weight: Keyword.get(opts, :weight, 0)})
    end
    GenServer.cast(from, {:remove_edge, to})
  end
  defoverridable remove_edge!: 2, remove_edge!: 3

  @doc false
  defp do_remove_edge(%{refs: refs, edges: edges} = object, node_pid, _opts) do
    refs = Map.reject(refs, fn 
      {ref, ^node_pid} ->
        Process.demonitor(ref)
        true
      _other -> false
    end)

    edges = Enum.reject(edges, fn
      {^node_pid, _weight} -> true
      _other -> false
    end)

    Map.merge(object, %{refs: refs, edges: edges})
  end

  defp do_add_edge(%{refs: refs, edges: edges} = object, node_pid, opts) do
    ref = Process.monitor(node_pid)
    refs = Map.put(refs, ref, node_pid)
    edges = List.insert_at(edges, -1, {node_pid, Keyword.get(opts, :weight, 0)})
    Map.merge(object, %{refs: refs, edges: edges})
  end

  @doc false
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{refs: refs} = object) when is_map_key(refs, ref) do
    object = do_remove_edge(object, Map.get(refs, ref), [])
    {:noreply, object}
  end

  def handle_info(msg, object) do
    super(msg, object)
  end
  defoverridable handle_info: 2

  @doc false
  def handle_call({:add_edge, node_pid, opts}, _from, %{} = object) do
    object = do_add_edge(object, node_pid, opts)
    {:reply, object, object}
  end

  def handle_call({:remove_edge, node_pid, opts}, _from, %{} = object) do
    object = do_remove_edge(object, node_pid, opts)
    {:reply, object, object}
  end

  def handle_call(msg, from, object) do
    super(msg, from, object)
  end
  defoverridable handle_call: 3

  @doc false
  def handle_cast({:add_edge, node_pid, opts}, %{} = object) do
    object = do_add_edge(object, node_pid, opts)
    {:noreply, object}
  end

  def handle_cast({:remove_edge, node_pid, opts}, %{} = object) do
    object = do_remove_edge(object, node_pid, opts)
    {:noreply, object}
  end

  def handle_cast(msg, object) do
    super(msg, object)
  end
  defoverridable handle_cast: 2
end


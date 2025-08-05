defmodule GenGraph.Tree do
  @moduledoc """
  GenGraph.Tree provides hierarchical tree functionality with parent-child relationships.

  Tree nodes extend GenGraph.Node functionality with additional features:
  - Automatic parent-child relationship management
  - Cycle detection to prevent circular references  
  - Child node tracking and synchronization
  - Automatic cleanup when child processes terminate

  ## Tree State

  In addition to GenGraph.Node state, each tree node maintains:
  - `parent_pid`: PID of the parent node (nil for root nodes)
  - `child_nodes`: List of child node PIDs

  ## Usage

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

      # Build tree relationships
      root = TreeNode.add_child(root, child1)
      root = TreeNode.add_child(root, child2)

  ## Cycle Prevention

  Tree nodes automatically prevent circular references by checking if a potential
  child is an ancestor of the current node before allowing the relationship.

  ## Automatic Synchronization

  The `child_nodes` list is automatically synchronized with the `edges` list,
  ensuring consistency between graph edges and tree relationships.
  """

  use GenGraph.Node, [
    parent_pid: nil,
    child_nodes: []
  ]

  def handle_info({:DOWN, ref, :process, _pid, _reason} = msg, %{refs: refs} = object) when is_map_key(refs, ref) do
    {:noreply, object} = super(msg, object)
    object = do_mirror_edges(object, Map.get(refs, ref))
    {:noreply, object}
  end

  def handle_info(msg, object) do
    super(msg, object)
  end
  defoverridable handle_info: 2

  def handle_call({:add_edge, node_pid, opts} = msg, from, %{} = object) do
    if is_ancestor?(object.parent_pid, node_pid) do
      {:reply, :error, object}
    else
      {:reply, object, object} = super(msg, from, object)
      object = do_mirror_edges(object, opts)
      GenServer.cast(node_pid, {:put, :parent_pid, self()})
      {:reply, object, object}
    end
  end

  def handle_call({:remove_edge, node_pid, opts} = msg, from, %{} = object) do
    {:reply, object, object} = super(msg, from, object)
    object = do_mirror_edges(object, opts)
    GenServer.cast(node_pid, {:put, :parent_pid, nil})
    {:reply, object, object}
  end

  def handle_call(msg, from, object) do
    super(msg, from, object)
  end
  defoverridable handle_call: 3

  def handle_cast({:add_edge, _chid_pid, opts} = msg, %{} = object) do
    {:noreply, object} = super(msg, object)
    object = do_mirror_edges(object, opts)
    {:noreply, object}
  end

  def handle_cast({:remove_edge, _child_pid, opts} = msg, %{} = object) do
    {:noreply, object} = super(msg, object)
    object = do_mirror_edges(object, opts)
    {:noreply, object}
  end

  def handle_cast(msg, object) do
    super(msg, object)
  end
  defoverridable handle_cast: 2

  defp do_mirror_edges(object, _opts) do
    child_nodes = Enum.map(object.edges, fn({child_pid, _weight}) -> child_pid end)
    Map.put(object, :child_nodes, child_nodes)
  end

  @doc """
  Adds a child node to a parent node, creating a parent-child relationship.

  This function creates an edge from parent to child and sets up the tree relationship.
  It prevents circular references by checking if the child is an ancestor of the parent.

  ## Parameters

  - `parent`: Parent node (PID or GenObject struct)
  - `child`: Child node (PID or GenObject struct) 
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Numeric weight for the edge (default: 0)

  ## Examples

      # Add child relationship
      parent = TreeNode.add_child(parent, child)

      # Add child with weight
      parent = TreeNode.add_child(parent, child, weight: 1)

  ## Returns

  Returns the updated parent node struct, or `:error` if the operation would create a cycle.

  ## Cycle Prevention

  If adding the child would create a circular reference (child is an ancestor of parent),
  the function returns `:error` and no relationship is created.
  """
  def add_child(parent, child, opts \\ [])
  def add_child(%{pid: parent_pid}, child, opts) when is_pid(parent_pid) and is_list(opts) do
    add_child(parent_pid, child, opts)
  end
  def add_child(parent, %{pid: child_pid}, opts) when is_pid(child_pid) and is_list(opts) do
    add_child(parent, child_pid, opts)
  end
  def add_child(parent, child, opts) when is_pid(parent) and is_pid(child) and is_list(opts) do
    GenServer.call(parent, {:add_edge, child, opts})
  end
  defoverridable add_child: 2, add_child: 3

  @doc """
  Asynchronously adds a child node to a parent node using GenServer.cast.

  Similar to `add_child/3` but uses asynchronous messaging. Note that cycle 
  detection is not performed in the async version.

  ## Parameters

  - `parent`: Parent node (PID or GenObject struct)
  - `child`: Child node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Numeric weight for the edge (default: 0)

  ## Examples

      # Async child addition
      TreeNode.add_child!(parent, child)

  ## Returns

  Returns `:ok` immediately without waiting for completion.

  ## Warning

  This async version does not perform cycle detection, so use with caution
  to avoid creating circular references.
  """
  def add_child!(parent, child, opts \\ [])
  def add_child!(%{pid: parent_pid}, child, opts) when is_pid(parent_pid) and is_list(opts) do
    add_child!(parent_pid, child, opts)
  end
  def add_child!(parent, %{pid: child_pid}, opts) when is_pid(child_pid) and is_list(opts) do
    add_child!(parent, child_pid, opts)
  end
  def add_child!(parent, child, opts) when is_pid(parent) and is_pid(child) and is_list(opts) do
    GenServer.cast(parent, {:add_edge, child, opts})
  end
  defoverridable add_child!: 2, add_child!: 3

  @doc """
  Removes a child node from a parent node, breaking the parent-child relationship.

  This function removes the edge from parent to child and clears the child's parent_pid.

  ## Parameters

  - `parent`: Parent node (PID or GenObject struct)
  - `child`: Child node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Specific weight of relationship to remove (default: 0)

  ## Examples

      # Remove child relationship
      parent = TreeNode.remove_child(parent, child)

  ## Returns

  Returns the updated parent node struct.

  ## Side Effects

  - Removes the edge from parent's edges list
  - Removes child PID from parent's child_nodes list  
  - Sets child's parent_pid to nil
  """
  def remove_child(parent, child, opts \\ [])
  def remove_child(%{pid: parent_pid}, child, opts) when is_pid(parent_pid) and is_list(opts) do
    remove_child(parent_pid, child, opts)
  end
  def remove_child(parent, %{pid: child_pid}, opts) when is_pid(child_pid) and is_list(opts) do
    remove_child(parent, child_pid, opts)
  end
  def remove_child(parent, child, opts) when is_pid(parent) and is_pid(child) and is_list(opts) do
    GenServer.call(parent, {:remove_edge, child, opts})
  end
  defoverridable remove_child: 2, remove_child: 3

  @doc """
  Asynchronously removes a child node from a parent node using GenServer.cast.

  Similar to `remove_child/3` but uses asynchronous messaging for better performance
  when you don't need to wait for confirmation of the relationship removal.

  ## Parameters

  - `parent`: Parent node (PID or GenObject struct)
  - `child`: Child node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Specific weight of relationship to remove (default: 0)

  ## Examples

      # Async child removal
      TreeNode.remove_child!(parent, child)

  ## Returns

  Returns `:ok` immediately without waiting for completion.
  """
  def remove_child!(parent, child, opts \\ [])
  def remove_child!(%{pid: parent_pid}, child, opts) when is_pid(parent_pid) and is_list(opts) do
    remove_child!(parent_pid, child, opts)
  end
  def remove_child!(parent, %{pid: child_pid}, opts) when is_pid(child_pid) and is_list(opts) do
    remove_child!(parent, child_pid, opts)
  end
  def remove_child!(parent, child, opts) when is_pid(parent) and is_pid(child) and is_list(opts) do
    GenServer.cast(parent, {:remove_edge, child, opts})
  end
  defoverridable remove_child!: 2, remove_child!: 3

  defp is_ancestor?(nil, _child_pid) do
    false
  end

  defp is_ancestor?(pid, pid) do
    true
  end

  defp is_ancestor?(ancestor_pid, child_pid) do
    is_ancestor?(GenServer.call(ancestor_pid, {:get, :parent_pid}), child_pid)
  end
end

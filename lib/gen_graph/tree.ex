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
      root = TreeNode.append_child(root, child1)
      root = TreeNode.append_child(root, child2)

  ## Cycle Prevention

  Tree nodes automatically prevent circular references by checking if a potential
  child is an ancestor of the current node before allowing the relationship.

  ## Automatic Synchronization

  The `child_nodes` list is automatically synchronized with the `edges` list,
  ensuring consistency between graph edges and tree relationships.
  """

  import GenGraph, only: [
    to_pid: 1,
    is_node_or_pid: 1
  ]

  use GenGraph.Node, [
    parent_pid: nil,
    child_nodes: []
  ]

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
      parent = TreeNode.append_child(parent, child)

      # Add child with weight
      parent = TreeNode.append_child(parent, child, weight: 1)

  ## Returns

  Returns the updated parent node struct, or `:error` if the operation would create a cycle.

  ## Cycle Prevention

  If adding the child would create a circular reference (child is an ancestor of parent),
  the function returns `:error` and no relationship is created.
  """
  def append_child(parent, child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(child) and is_list(opts) do
    parent = to_pid(parent)
    child = to_pid(child)
    GenServer.call(parent, {:append_child, child, opts})
  end
  defoverridable append_child: 2, append_child: 3

  @doc """
  Asynchronously adds a child node to a parent node using GenServer.cast.

  Similar to `append_child/3` but uses asynchronous messaging. Note that cycle 
  detection is not performed in the async version.

  ## Parameters

  - `parent`: Parent node (PID or GenObject struct)
  - `child`: Child node (PID or GenObject struct)
  - `opts`: Keyword list of options

  ## Options

  - `:weight` - Numeric weight for the edge (default: 0)

  ## Examples

      # Async child addition
      TreeNode.append_child!(parent, child)

  ## Returns

  Returns `:ok` immediately without waiting for completion.

  ## Warning

  This async version does not perform cycle detection, so use with caution
  to avoid creating circular references.
  """
  def append_child!(parent, child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(child) and is_list(opts) do
    parent = to_pid(parent)
    child = to_pid(child)
    GenServer.cast(parent, {:append_child, child, opts})
  end
  defoverridable append_child!: 2, append_child!: 3

  def insert_before(parent, new_child, reference_child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(new_child) and is_node_or_pid(reference_child) and is_list(opts) do
    parent = to_pid(parent)
    new_child = to_pid(new_child)
    reference_child = to_pid(reference_child)
    GenServer.call(parent, {:insert_before, new_child, reference_child, opts})
  end
  defoverridable insert_before: 3, insert_before: 4

  def insert_before!(parent, new_child, reference_child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(new_child) and is_node_or_pid(reference_child) and is_list(opts) do
    parent = to_pid(parent)
    new_child = to_pid(new_child)
    reference_child = to_pid(reference_child)
    GenServer.cast(parent, {:insert_before, new_child, reference_child, opts})
  end
  defoverridable insert_before!: 3, insert_before!: 4

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
  def remove_child(parent, child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(child) and is_list(opts) do
    parent = to_pid(parent)
    child = to_pid(child)
    GenServer.call(parent, {:remove_child, child, opts})
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
  def remove_child!(parent, child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(child) and is_list(opts) do
    parent = to_pid(parent)
    child = to_pid(child)
    GenServer.cast(parent, {:remove_child, child, opts})
  end
  defoverridable remove_child!: 2, remove_child!: 3

  def replace_child(parent, new_child, old_child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(new_child) and is_node_or_pid(old_child) and is_list(opts) do
    parent = to_pid(parent)
    new_child = to_pid(new_child)
    old_child = to_pid(old_child)
    GenServer.call(parent, {:replace_child, new_child, old_child, opts})
  end
  defoverridable replace_child: 3, replace_child: 4

  def replace_child!(parent, new_child, old_child, opts \\ []) when is_node_or_pid(parent) and is_node_or_pid(new_child) and is_node_or_pid(old_child) and is_list(opts) do
    parent = to_pid(parent)
    new_child = to_pid(new_child)
    old_child = to_pid(old_child)
    GenServer.cast(parent, {:replace_child, new_child, old_child, opts})
  end
  defoverridable replace_child!: 3, replace_child!: 4

  defp is_ancestor?(nil, _child_pid) do
    false
  end

  defp is_ancestor?(pid, pid) do
    true
  end

  defp is_ancestor?(ancestor_pid, child_pid) do
    is_ancestor?(GenServer.call(ancestor_pid, {:get, :parent_pid}), child_pid)
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason} = msg, %{refs: refs} = object) when is_map_key(refs, ref) do
    {:noreply, object} = super(msg, object)
    case do_remove_child(object, Map.get(refs, ref), []) do
      :error -> {:noreply, object}
      object -> {:noreply, object}
    end
  end

  def handle_info(msg, object) do
    super(msg, object)
  end
  defoverridable handle_info: 2

  def handle_call({:append_child, child_pid, opts}, from, %{} = object) do
    if is_ancestor?(object.parent_pid, child_pid) do
      {:reply, :error, object}
    else
      {:reply, object, object} = handle_call({:add_edge, child_pid, opts}, from, object)
      object = do_append_child(object, child_pid, opts)
      GenServer.cast(child_pid, {:put, :parent_pid, self()})
      {:reply, object, object}
    end
  end

  def handle_call({:insert_before, new_child_pid, reference_child_pid, opts}, from, object) do
    if is_ancestor?(object.parent_pid, new_child_pid) do
      {:reply, :error, object}
    else
      case do_insert_before(object, new_child_pid, reference_child_pid, opts) do
        :error -> {:reply, :error, object}
        object ->
          {:reply, object, object} = handle_call({:add_edge, new_child_pid, opts}, from, object)
          GenServer.cast(new_child_pid, {:put, :parent_pid, self()})
          {:reply, object, object}
      end
    end
  end

  def handle_call({:remove_child, child_pid, opts}, from, %{} = object) do
    {:reply, object, object} = handle_call({:remove_edge, child_pid, opts}, from, object)
    case do_remove_child(object, child_pid, opts) do
      :error -> {:reply, :error, object}
      object ->
        {:reply, object, object}
    end
  end

  def handle_call({:replace_child, new_child_pid, old_child_pid, opts}, from, object) do
    if is_ancestor?(object.parent_pid, new_child_pid) do
      {:reply, :error, object}
    else
      case do_replace_child(object, new_child_pid, old_child_pid, opts) do
        :error -> {:reply, :error, object}
        object ->
          {:reply, object, object} = handle_call({:add_edge, new_child_pid, opts}, from, object)
          GenServer.cast(new_child_pid, {:put, :parent_pid, self()})
          {:reply, object, object}
      end
    end
  end

  def handle_call(msg, from, object) do
    super(msg, from, object)
  end
  defoverridable handle_call: 3

  def handle_cast({:append_child, child_pid, opts}, object) do
    {:noreply, object} = handle_cast({:add_edge, child_pid, opts}, object)
    object = do_append_child(object, child_pid, opts)
    {:noreply, object}
  end

  def handle_cast({:insert_before, new_child_pid, reference_child_pid, opts}, object) do
    if is_ancestor?(object.parent_pid, new_child_pid) do
      {:noreply, object}
    else
      case do_insert_before(object, new_child_pid, reference_child_pid, opts) do
        :error -> {:noreply, object}
        object ->
          {:noreply, object} = handle_cast({:add_edge, new_child_pid, opts}, object)
          GenServer.cast(new_child_pid, {:put, :parent_pid, self()})
          {:noreply, object}
      end
    end
  end

  def handle_cast({:remove_child, child_pid, opts}, object) do
    {:noreply, object} = handle_cast({:remove_edge, child_pid, opts}, object)
    case do_remove_child(object, child_pid, opts) do
      :error -> {:noreply, object}
      object -> {:noreply, object}
    end
  end

  def handle_cast({:replace_child, new_child_pid, old_child_pid, opts}, object) do
    if is_ancestor?(object.parent_pid, new_child_pid) do
      {:noreply, object}
    else
      case do_replace_child(object, new_child_pid, old_child_pid, opts) do
        :error -> {:noreply, object}
        object ->
          {:noreply, object} = handle_cast({:add_edge, new_child_pid, opts}, object)
          GenServer.cast(new_child_pid, {:put, :parent_pid, self()})
          {:noreply, object}
      end
    end
  end

  def handle_cast(msg, object) do
    super(msg, object)
  end
  defoverridable handle_cast: 2

  defp do_append_child(%{child_nodes: child_nodes} = object, child_pid, _opts) do
    child_nodes = List.insert_at(child_nodes, -1, child_pid)
    Map.put(object, :child_nodes, child_nodes)
  end

  defp do_insert_before(object, new_child_pid, reference_child_pid, opts) do
    if Enum.member?(object.child_nodes, reference_child_pid) do
      new_child = GenGraph.Node.get(new_child_pid)
      object = cond do
        (new_child.parent_pid == self()) ->
          do_remove_child(object, new_child_pid, opts)
        is_pid(new_child.parent_pid) ->
          GenServer.cast(new_child.parent_pid, {:remove_child, new_child, []})
          object
        true -> object
      end

      child_nodes = Enum.reduce(object.child_nodes, [], fn
        ^reference_child_pid, child_nodes ->
          [reference_child_pid, new_child_pid | child_nodes]

        child_pid, child_nodes -> [child_pid | child_nodes]
      end)
      |> Enum.reverse()

      Map.put(object, :child_nodes, child_nodes)
    else
      :error
    end
  end

  defp do_remove_child(%{child_nodes: child_nodes} = object, child_pid, _opts) do
    GenServer.cast(child_pid, {:put_lazy, :parent_pid, fn(child) ->
      if child.parent_pid == object.pid do
        nil
      else
        child.parent_pid
      end
    end})

    case Enum.find_index(child_nodes, &(&1 == child_pid)) do
      nil -> :error
      idx ->
        child_nodes = List.delete_at(child_nodes, idx)
        Map.put(object, :child_nodes, child_nodes)
    end
  end

  defp do_replace_child(object, new_child_pid, old_child_pid, _opts) do
    GenServer.cast(old_child_pid, {:put_lazy, :parent_pid, fn(child) ->
      if child.parent_pid == object.pid do
        nil
      else
        child.parent_pid
      end
    end})

    if Enum.member?(object.child_nodes, old_child_pid) do
      if parent_pid = GenGraph.Node.get(new_child_pid, :parent_pid),
        do: GenServer.call(parent_pid, {:remove_child, new_child_pid, []})

      child_nodes = Enum.map(object.child_nodes, fn
        ^old_child_pid -> new_child_pid
        child_pid -> child_pid
      end)

      Map.put(object, :child_nodes, child_nodes)
    else
      :error
    end
  end
end

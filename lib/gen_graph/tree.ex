defmodule GenGraph.Tree do
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

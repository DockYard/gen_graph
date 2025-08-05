defmodule GenGraph.Node do
  use GenObject, [
    refs: %{},
    edges: []
  ]

  def add_edge(from, to, opts \\ [])
  def add_edge(%{pid: from_pid}, %{pid: to_pid}, opts) when is_pid(from_pid) and is_pid(to_pid) and is_list(opts) do
    add_edge(from_pid, to_pid, opts)
  end
  def add_edge(%{pid: pid}, to, opts) when is_pid(pid) and is_list(opts) do
    add_edge(pid, to, opts)
  end
  def add_edge(from, %{pid: pid}, opts) when is_pid(pid) and is_list(opts) do
    add_edge(from, pid, opts)
  end
  def add_edge(from, to, opts) when is_pid(from) and is_pid(to) and is_list(opts) do
    if Keyword.get(opts, :bidirectional, false) do
      GenServer.call(to, {:add_edge, from, weight: Keyword.get(opts, :weight, 0)})
    end
    GenServer.call(from, {:add_edge, to, weight: Keyword.get(opts, :weight, 0)})
  end
  defoverridable add_edge: 2, add_edge: 3

  def add_edge!(from, to, opts \\ [])
  def add_edge!(%{pid: from_pid}, %{pid: to_pid}, opts) when is_pid(from_pid) and is_pid(to_pid) and is_list(opts) do
    add_edge!(from_pid, to_pid, opts)
  end
  def add_edge!(%{pid: pid}, to, opts) when is_pid(pid) and is_list(opts) do
    add_edge!(pid, to, opts)
  end
  def add_edge!(from, %{pid: pid}, opts) when is_pid(pid) and is_list(opts) do
    add_edge!(from, pid, opts)
  end
  def add_edge!(from, to, opts) when is_pid(from) and is_pid(to) and is_list(opts) do
    if Keyword.get(opts, :bidirectional, false) do
      GenServer.cast(to, {:add_edge, from, weight: Keyword.get(opts, :weight, 0)})
    end
    GenServer.cast(from, {:add_edge, to, weight: Keyword.get(opts, :weight, 0)})
  end
  defoverridable add_edge!: 2, add_edge!: 3

  def remove_edge(from, to, opts \\ [])
  def remove_edge(%{pid: from_pid}, %{pid: to_pid}, opts) when is_pid(from_pid) and is_pid(to_pid) and is_list(opts) do
    remove_edge(from_pid, to_pid, opts)
  end
  def remove_edge(%{pid: pid}, to, opts) when is_pid(pid) and is_list(opts) do
    remove_edge(pid, to, opts)
  end
  def remove_edge(from, %{pid: pid}, opts) when is_pid(pid) and is_list(opts) do
    remove_edge(from, pid, opts)
  end
  def remove_edge(from, to, opts) when is_pid(from) and is_pid(to) and is_list(opts) do
    weight = Keyword.get(opts, :weight, 0)
    if Keyword.get(opts, :bidirectional, false) do
      GenServer.call(to, {:remove_edge, from, weight: weight})
    end
    GenServer.call(from, {:remove_edge, to, weight: weight})
  end
  defoverridable remove_edge: 2, remove_edge: 3

  def remove_edge!(from, to, opts \\ [])
  def remove_edge!(%{pid: from_pid}, %{pid: to_pid}, opts) when is_pid(from_pid) and is_pid(to_pid) and is_list(opts) do
    remove_edge!(from_pid, to_pid, opts)
  end
  def remove_edge!(%{pid: pid}, to, opts) when is_pid(pid) and is_list(opts) do
    remove_edge!(pid, to, opts)
  end
  def remove_edge!(from, %{pid: pid}, opts) when is_pid(pid) and is_list(opts) do
    remove_edge!(from, pid, opts)
  end
  def remove_edge!(from, to, opts) when is_pid(from) and is_pid(to) and is_list(opts) do
    if Keyword.get(opts, :bidirectional, false) do
      GenServer.cast(to, {:remove_edge, from, weight: Keyword.get(opts, :weight, 0)})
    end
    GenServer.cast(from, {:remove_edge, to})
  end
  defoverridable remove_edge!: 2, remove_edge!: 3

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

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{refs: refs} = object) when is_map_key(refs, ref) do
    object = do_remove_edge(object, Map.get(refs, ref), [])
    {:noreply, object}
  end

  def handle_info(msg, object) do
    super(msg, object)
  end
  defoverridable handle_info: 2

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


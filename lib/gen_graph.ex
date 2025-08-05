defmodule GenGraph do
  # defmacro __using__(_opts) do
  #   quote do
  #     def handle_call({:add_edge, node_pid, _opts}, _from, %__MODULE__{refs: refs} = object) do
  #       refs = GenGraph.Node.monitor(refs, node_pid)
  #       object = Map.put(object, :refs, refs)
  #       {:reply, object, object}
  #     end
  #
  #     def handle_call({:remove_edge, node_pid, _opts}, _from, %__MODULE__{refs: refs} = object) do
  #       refs = GenGraph.Node.demonitor(refs, node_pid)
  #       object = Map.put(object, :refs, refs)
  #       {:reply, object, object}
  #     end
  #
  #     @doc false
  #     def add_edge(from, to, opts \\ []) do
  #       GenGraph.add_edge(from, to, opts)
  #     end
  #     defwithhold add_edge: 2, add_edge: 3
  #     defoverridable add_edge: 2, add_edge: 3
  #
  #     @doc false
  #     def remove_edge(from, to, opts \\ []) do
  #       GenGraph.remove_edge(from, to, opts)
  #     end
  #     defwithhold remove_edge: 2, remove_edge: 3
  #     defoverridable remove_edge: 2, remove_edge: 3
  #   end
  # end
  #
  # @doc """
  # Adds an edge between two nodes.
  #
  # `from` and `to` can be `pid`s or `struct`s
  # """
  # def add_edge(from, to, opts \\ [])
  # def add_edge(pid_or_object, %{pid: pid}, opts) when is_pid(pid) do
  #   add_edge(pid_or_object, pid, opts)
  # end
  # def add_edge(%{pid: pid}, node, opts) when is_pid(pid) do
  #   add_edge(pid, node, opts)
  # end
  # def add_edge(pid, node_pid, opts) when is_pid(pid) and is_pid(node_pid) do
  #   GenServer.call(pid, {:add_edge, node_pid, opts})
  # end
  #
  # @doc """
  # Removes an edge between two nodes.
  #
  # `from` and `to` can be `pid`s or `struct`s
  # """
  # def remove_edge(from, to, opts \\ [])
  # def remove_edge(pid_or_object, %{pid: pid}, opts) when is_pid(pid) do
  #   remove_edge(pid_or_object, pid, opts)
  # end
  # def remove_edge(%{pid: pid}, node, opts) when is_pid(pid) do
  #   remove_edge(pid, node, opts)
  # end
  # def remove_edge(pid, node_pid, opts) when is_pid(pid) and is_pid(node_pid) do
  #   GenServer.call(pid, {:remove_edge, node_pid, opts})
  # end
end

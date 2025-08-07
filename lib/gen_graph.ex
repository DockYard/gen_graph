defmodule GenGraph do
  @moduledoc false

  @doc false
  defguard is_node_or_pid(node_or_pid) when is_map(node_or_pid) or is_pid(node_or_pid)

  @doc false
  def to_pid(%{pid: pid}) when is_pid(pid),
    do: pid
  def to_pid(pid) when is_pid(pid),
    do: pid
end

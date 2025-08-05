defmodule GrandParent do
  fields =
    GenGraph.Tree.__info__(:struct)
    |> Enum.map(&{&1.field, &1.default})
    |> Keyword.merge(name: "", age: nil)

  use Inherit, fields

  (
    (
      def get(var_1) do
        apply(GenObject, :get, [var_1])
      end

      Inherit.update_function_defs(:get, 1, %{delegate: true})
    )

    (
      def get(var_1, var_2) do
        apply(GenObject, :get, [var_1, var_2])
      end

      Inherit.update_function_defs(:get, 2, %{delegate: true})
    )

    (
      def put(var_1, var_2, var_3) do
        apply(GenObject, :put, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:put, 3, %{delegate: true})
    )

    (
      def put!(var_1, var_2, var_3) do
        apply(GenObject, :put!, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:put!, 3, %{delegate: true})
    )

    (
      def put_lazy(var_1, var_2, var_3) do
        apply(GenObject, :put_lazy, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:put_lazy, 3, %{delegate: true})
    )

    (
      def put_lazy!(var_1, var_2, var_3) do
        apply(GenObject, :put_lazy!, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:put_lazy!, 3, %{delegate: true})
    )

    (
      def merge(var_1, var_2) do
        apply(GenObject, :merge, [var_1, var_2])
      end

      Inherit.update_function_defs(:merge, 2, %{delegate: true})
    )

    (
      def merge!(var_1, var_2) do
        apply(GenObject, :merge!, [var_1, var_2])
      end

      Inherit.update_function_defs(:merge!, 2, %{delegate: true})
    )

    (
      def merge_lazy(var_1, var_2) do
        apply(GenObject, :merge_lazy, [var_1, var_2])
      end

      Inherit.update_function_defs(:merge_lazy, 2, %{delegate: true})
    )

    (
      def merge_lazy!(var_1, var_2) do
        apply(GenObject, :merge_lazy!, [var_1, var_2])
      end

      Inherit.update_function_defs(:merge_lazy!, 2, %{delegate: true})
    )

    (
      def handle_call(var_1, var_2, var_3) do
        apply(GenObject, :handle_call, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:handle_call, 3, %{delegate: true})
    )

    (
      def handle_cast(var_1, var_2) do
        apply(GenObject, :handle_cast, [var_1, var_2])
      end

      Inherit.update_function_defs(:handle_cast, 2, %{delegate: true})
    )

    (
      def handle_info(var_1, var_2) do
        apply(GenObject, :handle_info, [var_1, var_2])
      end

      Inherit.update_function_defs(:handle_info, 2, %{delegate: true})
    )

    defoverridable handle_info: 2, handle_cast: 2, handle_call: 3
    use GenObject, name: "", age: nil
  )

  (
    (
      def handle_call(var_1, var_2, var_3) do
        apply(GenGraph.Node, :handle_call, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:handle_call, 3, %{delegate: true})
    )

    (
      def handle_cast(var_1, var_2) do
        apply(GenGraph.Node, :handle_cast, [var_1, var_2])
      end

      Inherit.update_function_defs(:handle_cast, 2, %{delegate: true})
    )

    (
      def handle_info(var_1, var_2) do
        apply(GenGraph.Node, :handle_info, [var_1, var_2])
      end

      Inherit.update_function_defs(:handle_info, 2, %{delegate: true})
    )

    (
      def start_link() do
        apply(GenGraph.Node, :start_link, [])
      end

      Inherit.update_function_defs(:start_link, 0, %{delegate: true})
    )

    (
      def start_link(var_1) do
        apply(GenGraph.Node, :start_link, [var_1])
      end

      Inherit.update_function_defs(:start_link, 1, %{delegate: true})
    )

    (
      def start() do
        apply(GenGraph.Node, :start, [])
      end

      Inherit.update_function_defs(:start, 0, %{delegate: true})
    )

    (
      def start(var_1) do
        apply(GenGraph.Node, :start, [var_1])
      end

      Inherit.update_function_defs(:start, 1, %{delegate: true})
    )

    (
      def child_spec(var_1) do
        apply(GenGraph.Node, :child_spec, [var_1])
      end

      Inherit.update_function_defs(:child_spec, 1, %{delegate: true})
    )

    (
      def new() do
        apply(GenGraph.Node, :new, [])
      end

      Inherit.update_function_defs(:new, 0, %{delegate: true})
    )

    (
      def new(var_1) do
        apply(GenGraph.Node, :new, [var_1])
      end

      Inherit.update_function_defs(:new, 1, %{delegate: true})
    )

    (
      def stop(var_1) do
        apply(GenGraph.Node, :stop, [var_1])
      end

      Inherit.update_function_defs(:stop, 1, %{delegate: true})
    )

    (
      def init(var_1) do
        apply(GenGraph.Node, :init, [var_1])
      end

      Inherit.update_function_defs(:init, 1, %{delegate: true})
    )

    (
      def add_edge(var_1, var_2, var_3) do
        apply(GenGraph.Node, :add_edge, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:add_edge, 3, %{delegate: true})
    )

    (
      def add_edge(var_1, var_2) do
        apply(GenGraph.Node, :add_edge, [var_1, var_2])
      end

      Inherit.update_function_defs(:add_edge, 2, %{delegate: true})
    )

    (
      def add_edge!(var_1, var_2, var_3) do
        apply(GenGraph.Node, :add_edge!, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:add_edge!, 3, %{delegate: true})
    )

    (
      def add_edge!(var_1, var_2) do
        apply(GenGraph.Node, :add_edge!, [var_1, var_2])
      end

      Inherit.update_function_defs(:add_edge!, 2, %{delegate: true})
    )

    (
      def remove_edge(var_1, var_2, var_3) do
        apply(GenGraph.Node, :remove_edge, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:remove_edge, 3, %{delegate: true})
    )

    (
      def remove_edge(var_1, var_2) do
        apply(GenGraph.Node, :remove_edge, [var_1, var_2])
      end

      Inherit.update_function_defs(:remove_edge, 2, %{delegate: true})
    )

    (
      def remove_edge!(var_1, var_2, var_3) do
        apply(GenGraph.Node, :remove_edge!, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:remove_edge!, 3, %{delegate: true})
    )

    (
      def remove_edge!(var_1, var_2) do
        apply(GenGraph.Node, :remove_edge!, [var_1, var_2])
      end

      Inherit.update_function_defs(:remove_edge!, 2, %{delegate: true})
    )

    defoverridable remove_edge!: 2,
                   remove_edge!: 3,
                   remove_edge: 2,
                   remove_edge: 3,
                   add_edge!: 2,
                   add_edge!: 3,
                   add_edge: 2,
                   add_edge: 3,
                   init: 1,
                   stop: 1,
                   new: 1,
                   new: 0,
                   child_spec: 1,
                   start: 1,
                   start: 0,
                   start_link: 1,
                   start_link: 0,
                   handle_info: 2,
                   handle_cast: 2,
                   handle_call: 3

    use GenGraph.Node, name: "", age: nil
  )

  (
    (
      def handle_call(var_1, var_2, var_3) do
        apply(GenGraph.Tree, :handle_call, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:handle_call, 3, %{delegate: true})
    )

    (
      def handle_cast(var_1, var_2) do
        apply(GenGraph.Tree, :handle_cast, [var_1, var_2])
      end

      Inherit.update_function_defs(:handle_cast, 2, %{delegate: true})
    )

    (
      def add_child(var_1, var_2, var_3) do
        apply(GenGraph.Tree, :add_child, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:add_child, 3, %{delegate: true})
    )

    (
      def add_child(var_1, var_2) do
        apply(GenGraph.Tree, :add_child, [var_1, var_2])
      end

      Inherit.update_function_defs(:add_child, 2, %{delegate: true})
    )

    (
      def add_child!(var_1, var_2, var_3) do
        apply(GenGraph.Tree, :add_child!, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:add_child!, 3, %{delegate: true})
    )

    (
      def add_child!(var_1, var_2) do
        apply(GenGraph.Tree, :add_child!, [var_1, var_2])
      end

      Inherit.update_function_defs(:add_child!, 2, %{delegate: true})
    )

    (
      def remove_child(var_1, var_2, var_3) do
        apply(GenGraph.Tree, :remove_child, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:remove_child, 3, %{delegate: true})
    )

    (
      def remove_child(var_1, var_2) do
        apply(GenGraph.Tree, :remove_child, [var_1, var_2])
      end

      Inherit.update_function_defs(:remove_child, 2, %{delegate: true})
    )

    (
      def remove_child!(var_1, var_2, var_3) do
        apply(GenGraph.Tree, :remove_child!, [var_1, var_2, var_3])
      end

      Inherit.update_function_defs(:remove_child!, 3, %{delegate: true})
    )

    (
      def remove_child!(var_1, var_2) do
        apply(GenGraph.Tree, :remove_child!, [var_1, var_2])
      end

      Inherit.update_function_defs(:remove_child!, 2, %{delegate: true})
    )

    defoverridable remove_child!: 2,
                   remove_child!: 3,
                   remove_child: 2,
                   remove_child: 3,
                   add_child!: 2,
                   add_child!: 3,
                   add_child: 2,
                   add_child: 3,
                   handle_cast: 2,
                   handle_call: 3

    []
  )
end
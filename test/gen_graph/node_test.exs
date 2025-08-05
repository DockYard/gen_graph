defmodule GenGraph.NodeTest do
  use ExUnit.Case
  doctest GenGraph

  test "add edge" do
    foo = Foo.new()
    bar = Bar.new()

    foo = Foo.add_edge(foo, bar)
    assert [{bar.pid, 0}] == foo.edges
    bar = Bar.get(bar)
    assert [] == bar.edges
  end

  test "add bidirectional edge" do
    foo = Foo.new()
    bar = Bar.new()

    foo = Foo.add_edge(foo, bar, bidirectional: true)
    assert [{bar.pid, 0}] == foo.edges
    bar = Bar.get(bar)
    assert [{foo.pid, 0}] == bar.edges
  end

  test "add weight to an edge" do
    foo = Foo.new()
    bar = Bar.new()

    foo = Foo.add_edge(foo, bar, weight: 2)
    assert [{bar.pid, 2}] == foo.edges
    bar = Bar.get(bar)
    assert [] == bar.edges
  end

  test "a node's edge will monitor node and update it's edges if node is killed" do
    foo = Foo.new()
    baz = Baz.new()

    foo = Foo.add_edge(foo, baz)

    assert [{baz.pid, 0}] == foo.edges
    Process.exit(baz.pid, :kill)
    :timer.sleep(1)
    foo = Foo.get(foo)
    assert [] == foo.edges
  end

  test "add circular relationships" do
    bar = Bar.new()
    foo = Foo.new()
    baz = Baz.new()

    bar = Bar.add_edge(bar, foo)
    foo = Foo.add_edge(foo, baz)
    baz = Baz.add_edge(baz, foo)
    baz = Baz.add_edge(baz, bar)

    assert [{foo.pid, 0}] == bar.edges
    assert [{baz.pid, 0}] == foo.edges
    assert [{foo.pid, 0}, {bar.pid, 0}] == baz.edges
  end

  test "can remove baz" do
    foo = Foo.new()
    baz = Baz.new()

    foo = Foo.add_edge(foo, baz)
    assert [{baz.pid, 0}] == foo.edges

    foo = Foo.remove_edge(foo, baz)
    assert [] == foo.edges
  end
end


defmodule GenGraph.TreeTest do
  use ExUnit.Case
  doctest GenGraph

  test "build tree" do
    grand_parent = GrandParent.new()
    parent1 = Parent.new()
    parent2 = Parent.new()
    child1 = Child.new()
    child2 = Child.new()
    child3 = Child.new()

    grand_parent = GrandParent.add_child(grand_parent, parent1)
    grand_parent = GrandParent.add_child(grand_parent, parent2)

    parent1 = Parent.add_child(parent1, child1.pid)
    parent1 = Parent.add_child(parent1.pid, child2)

    parent2 = Parent.add_child(parent2, child3)

    assert [parent1.pid, parent2.pid] == grand_parent.child_nodes
    assert [child1.pid, child2.pid] == parent1.child_nodes
    assert [child3.pid] == parent2.child_nodes
  end

  test "a child being killed will update parent's child_nodes" do
    parent = Parent.new()
    child = Child.new()

    parent = Parent.add_child(parent, child)

    assert [child.pid] == parent.child_nodes
    Process.exit(child.pid, :kill)
    :timer.sleep(1)
    parent = Parent.get(parent)
    assert [] == parent.child_nodes
  end

  test "cannot add circular relationships" do
    grand_parent = GrandParent.new()
    parent = Parent.new()
    child = Child.new()

    grand_parent = GrandParent.add_child(grand_parent, parent)
    parent = Parent.add_child(parent, child)

    assert :error == Child.add_child(child, parent)
    assert :error == Child.add_child(child, grand_parent)

    assert [parent.pid] == grand_parent.child_nodes
    assert [child.pid] == parent.child_nodes
    child = Child.get(child)
    assert [] == child.child_nodes
  end

  test "can remove child" do
    parent = Parent.new()
    child = Child.new()

    parent = Parent.add_child(parent, child)
    assert [child.pid] == parent.child_nodes

    parent = Parent.remove_child(parent, child)
    assert [] == parent.child_nodes
  end

  test "parent_pid is populated & removed when a child is added and removed" do
    parent = Parent.new()
    child = Child.new()

    parent = Parent.add_child(parent, child)
    assert parent.pid == Child.get(child, :parent_pid)

    _parent = Parent.remove_child(parent, child)
    :timer.sleep(1)
    assert nil == Child.get(child, :parent_pid)
  end
end



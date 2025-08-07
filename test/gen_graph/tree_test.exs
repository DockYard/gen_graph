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

    grand_parent = GrandParent.append_child(grand_parent, parent1)
    grand_parent = GrandParent.append_child(grand_parent, parent2)

    parent1 = Parent.append_child(parent1, child1.pid)
    parent1 = Parent.append_child(parent1.pid, child2)

    parent2 = Parent.append_child(parent2, child3)

    assert [parent1.pid, parent2.pid] == grand_parent.child_nodes
    assert [child1.pid, child2.pid] == parent1.child_nodes
    assert [child3.pid] == parent2.child_nodes
  end

  describe "append_child" do
    test "sync" do
      parent = Parent.new()
      child = Child.new()

      assert [] == parent.child_nodes
      parent = Parent.append_child(parent, child)
      assert [child.pid] == parent.child_nodes
    end

    test "async" do
      parent = Parent.new()
      child = Child.new()

      assert [] == parent.child_nodes
      :ok = Parent.append_child!(parent, child)
      :timer.sleep(1)
      parent = Parent.get(parent)
      assert [child.pid] == parent.child_nodes
    end

    test "cannot add circular relationships" do
      grand_parent = GrandParent.new()
      parent = Parent.new()
      child = Child.new()

      grand_parent = GrandParent.append_child(grand_parent, parent)
      parent = Parent.append_child(parent, child)

      assert :error == Child.append_child(child, parent)
      assert :error == Child.append_child(child, grand_parent)

      assert [parent.pid] == grand_parent.child_nodes
      assert [child.pid] == parent.child_nodes
      child = Child.get(child)
      assert [] == child.child_nodes
    end

    test "parent_pid is populated when child is appended" do
      parent = Parent.new()
      child = Child.new()

      assert nil == Child.get(child, :parent_pid)
      parent = Parent.append_child(parent, child)
      assert parent.pid == Child.get(child, :parent_pid)
    end
  end

  describe "insert_before" do
    test "sync" do
      parent = Parent.new()
      parent2 = Parent.new()
      child1 = Child.new()
      child2 = Child.new()
      child3 = Child.new()
      child4 = Child.new()

      parent = Parent.append_child(parent, child1)
      parent2 = Parent.append_child(parent2, child4)
      assert [child1.pid] == parent.child_nodes

      parent = Parent.insert_before(parent, child2, child1)
      assert [child2.pid, child1.pid] == parent.child_nodes

      assert :error == Parent.insert_before(parent, child4, child3)
      child4 = Child.get(child4)
      assert child4.parent_pid == parent2.pid
    end

    test "async" do
      parent = Parent.new()
      child1 = Child.new()
      child2 = Child.new()
      child3 = Child.new()
      child4 = Child.new()

      parent = Parent.append_child(parent, child1)
      assert [child1.pid] == parent.child_nodes

      :ok = Parent.insert_before!(parent, child2, child1)
      :timer.sleep(1)
      parent = Parent.get(parent)
      assert [child2.pid, child1.pid] == parent.child_nodes

      # fails silently
      assert :ok == Parent.insert_before!(parent, child4, child3)
      :timer.sleep(1)
      parent = Parent.get(parent)
      assert [child2.pid, child1.pid] == parent.child_nodes
    end

    test "cannot add circular relationships" do
      grand_parent = GrandParent.new()
      parent = Parent.new()
      child = Child.new()

      grand_parent = GrandParent.append_child(grand_parent, parent)
      parent = Parent.append_child(parent, child)

      assert :error == Parent.insert_before(parent, grand_parent, child)
      # fails silently
      assert :ok == Parent.insert_before!(parent, grand_parent, child)

      parent = Parent.get(parent)
      :timer.sleep(1)

      assert [parent.pid] == grand_parent.child_nodes
      assert [child.pid] == parent.child_nodes
    end

    test "parent_pid is populated when new child is inserted" do
      parent = Parent.new()
      child1 = Child.new()
      child2 = Child.new()

      parent = Parent.append_child(parent, child1)

      assert parent.pid == Child.get(child1, :parent_pid)
      assert nil == Child.get(child2, :parent_pid)
      parent = Parent.insert_before(parent, child2, child1)
      :timer.sleep(1)
      assert parent.pid == Child.get(child2, :parent_pid)
    end
  end

  describe "remove_child" do
    test "sync" do
      parent = Parent.new()
      child = Child.new()

      parent = Parent.append_child(parent, child)
      assert [child.pid] == parent.child_nodes
      parent = Parent.remove_child(parent, child)
      assert [] == parent.child_nodes

      # returns error if child is not parent's child
      assert :error == Parent.remove_child(parent, child)
    end

    test "async" do
      parent = Parent.new()
      child = Child.new()

      parent = Parent.append_child(parent, child)
      assert [child.pid] == parent.child_nodes
      :ok = Parent.remove_child!(parent, child)
      :timer.sleep(1)
      parent = Parent.get(parent)
      assert [] == parent.child_nodes

      # will fail silently
      :ok = Parent.remove_child!(parent, child)
    end

    test "parent_pid is removed from child" do
      parent = Parent.new()
      child = Child.new()

      parent = Parent.append_child(parent, child)
      child = Child.get(child)
      :timer.sleep(1)
      assert parent.pid == child.parent_pid
      _parent = Parent.remove_child(parent, child)
      :timer.sleep(1)
      child = Child.get(child)
      assert nil == child.parent_pid
    end
  end

  describe "replace_child" do
    test "sync" do
      parent = Parent.new()
      child1 = Child.new()
      child2 = Child.new()
      child3 = Child.new()

      parent = Parent.append_child(parent, child1)
      assert [child1.pid] == parent.child_nodes

      parent = Parent.replace_child(parent, child2, child1)
      assert [child2.pid] == parent.child_nodes

      assert :error == Parent.replace_child(parent, child3, child1)
    end

    test "async" do
      parent = Parent.new()
      child1 = Child.new()
      child2 = Child.new()
      child3 = Child.new()

      parent = Parent.append_child(parent, child1)
      assert [child1.pid] == parent.child_nodes

      :ok = Parent.replace_child!(parent, child2, child1)
      :timer.sleep(1)
      parent = Parent.get(parent)
      assert [child2.pid] == parent.child_nodes

      # fails silently
      assert :ok == Parent.insert_before!(parent, child3, child1)
      :timer.sleep(1)
      parent = Parent.get(parent)
      assert [child2.pid] == parent.child_nodes
    end

    test "cannot add circular relationships" do
      grand_parent = GrandParent.new()
      parent = Parent.new()
      child = Child.new()

      grand_parent = GrandParent.append_child(grand_parent, parent)
      parent = Parent.append_child(parent, child)

      assert :error == Parent.replace_child(parent, grand_parent, child)
      # fails silently
      assert :ok == Parent.replace_child!(parent, grand_parent, child)

      parent = Parent.get(parent)
      :timer.sleep(1)

      assert [parent.pid] == grand_parent.child_nodes
      assert [child.pid] == parent.child_nodes
    end

    test "parent_pids are updated when children are replaced" do
      parent = Parent.new()
      child1 = Child.new()
      child2 = Child.new()

      parent = Parent.append_child(parent, child1)

      assert parent.pid == Child.get(child1, :parent_pid)
      assert nil == Child.get(child2, :parent_pid)
      parent = Parent.replace_child(parent, child2, child1)
      :timer.sleep(1)
      assert parent.pid == Child.get(child2, :parent_pid)
      assert nil == Child.get(child1, :parent_pid)
    end
  end

  test "a child being killed will update parent's child_nodes" do
    parent = Parent.new()
    child = Child.new()

    parent = Parent.append_child(parent, child)

    assert [child.pid] == parent.child_nodes
    Process.exit(child.pid, :kill)
    :timer.sleep(1)
    parent = Parent.get(parent)
    assert [] == parent.child_nodes
  end
end



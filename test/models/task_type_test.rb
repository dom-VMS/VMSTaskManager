require 'test_helper'
require 'public_activity/testing'
PublicActivity.enabled = false

class TaskTypeTest < ActiveSupport::TestCase

  test "task_type should be saved" do
    task_type = TaskType.new(name: "Test", description: "This is a test")
    assert task_type.save, "task_type should be allowed to be saved."
  end

  test "task_type should not be saved without name" do
    task_type = TaskType.new(description: "This is a test")
    assert !task_type.save, "task_type should be allowed to be saved without a title"
  end

  test "task_type should save even without a description" do
    task_type = TaskType.new(name: "Test")
    assert task_type.save, "task_type should be allowed to be saved without a description."
  end

end

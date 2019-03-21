require 'test_helper'
require 'public_activity/testing'
PublicActivity.enabled = false

class TaskTest < ActiveSupport::TestCase

  test "task should be saved" do
    task = Task.new(title: "Test", description: "Test Description", priority: 4, status: 1, percentComplete: 100, task_type_id: task_types(:maintenance).id, attachments: nil)
    assert task.save, "Task should be allowed to be saved."
  end

  test "task should not be saved without a task_type_id" do
    task = Task.new(title: "Test", description: "Test Description", priority: 4, status: 1, percentComplete: 100, task_type_id: nil, attachments: nil)
    assert !task.save, "Task should not be saved without a task_type_id."
  end

end

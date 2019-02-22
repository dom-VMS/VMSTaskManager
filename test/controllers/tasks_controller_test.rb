require 'test_helper'

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "this task should fail" do
     task = Task.new
     assert_not task.save
   end
end

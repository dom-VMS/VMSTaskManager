require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user should be saved" do
    user = User.new(f_name: "Test", l_name: "Test", email: "test@varland.com", password: "test", employee_number: "111")
    assert user.save, "User should be allowed to be saved."
  end

  test "should not save user without f_name" do
    user = User.new(l_name: "Test", email: "test@varland.com", password: "test", employee_number: "111")
    assert !user.save, "Saved user without a first name"
  end

  test "should not save user without l_name" do
    user = User.new(f_name: "Test", email: "test@varland.com", password: "test", employee_number: "111")
    assert !user.save, "Saved user without a name"
  end

  test "should not save user without employee_number" do
    user = User.new(f_name: "Test", l_name: "Test", email: "test@varland.com", password: "test")
    assert !user.save, "Saved user without an employee_number"
  end

  test "should not save user without an email" do
    user = User.new(f_name: "Test", l_name: "Test", password: "test", employee_number: "111")
    assert !user.save, "Saved user without an email."
  end

  test "should not save user without a password" do
    user = User.new(f_name: "Test", l_name: "Test", email: "test@varland.com", employee_number: "111")
    assert !user.save, "Saved user witout a password"
  end

  test "should not save user because password is too short" do
    user = User.new(f_name: "Test", l_name: "Test", email: "test@varland.com", password: "te", employee_number: "111")
    assert !user.save, "Saved user even though password is too short"
  end

  test "should not save user because email is invalid" do
    user = User.new(f_name: "Test", l_name: "Test", email: "testvarland.com", password: "test", employee_number: "111")
    assert !user.save, "Saved user with invalid email."
  end
  
end

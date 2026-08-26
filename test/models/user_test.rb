require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without name" do
    user = User.new(password: "password123", password_confirmation: "password123")
    assert_not user.save, "Saved user without name"
  end

  test "should not save user with duplicate name" do
    user = User.new(name: users(:one).name, password: "password123", password_confirmation: "password123")
    assert_not user.save, "Saved user with duplicate name"
  end

  test "should save valid user" do
    user = User.new(name: "unique_name", password: "password123", password_confirmation: "password123")
    assert user.save
  end

  test "admin? returns true for admin role" do
    assert users(:admin).admin?
  end

  test "admin? returns false for regular user" do
    assert_not users(:one).admin?
  end

  test "should validate role inclusion" do
    user = User.new(name: "test_role", password: "password123", password_confirmation: "password123", role: "superadmin")
    assert_not user.save
  end

  test "should have many notes" do
    assert_respond_to users(:one), :notes
  end

  test "should have many collections" do
    assert_respond_to users(:one), :collections
  end

  test "should have many friends" do
    assert_respond_to users(:one), :friends
  end
end

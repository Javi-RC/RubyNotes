require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { name: "brand_new_user", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to root_path
  end

  test "should require login for index" do
    get users_url
    assert_redirected_to new_session_path
  end

  test "should require admin for index" do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
    get users_url
    assert_redirected_to home_path
  end

  test "admin can access index" do
    post sessions_url, params: { name: users(:admin).name, password: "password123" }
    get users_url
    assert_response :success
  end
end

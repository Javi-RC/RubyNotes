require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def sign_in(user)
    post sessions_url, params: { name: user.name, password: "password123" }
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { name: "brand_new_user", password: "password123",
                                        password_confirmation: "password123" } }
    end
    assert_redirected_to root_path
  end

  test "sign-up cannot grant itself the admin role" do
    post users_url, params: { user: { name: "sneaky", password: "password123",
                                      password_confirmation: "password123", role: "admin" } }
    assert_equal "user", User.find_by(name: "sneaky").role
  end

  test "should require login for index" do
    get users_url
    assert_redirected_to new_session_path
  end

  test "should require admin for index" do
    sign_in users(:one)
    get users_url
    assert_redirected_to home_path
  end

  test "admin can access index" do
    sign_in users(:admin)
    get users_url
    assert_response :success
  end

  test "a user can edit their own account" do
    sign_in users(:one)
    get edit_user_url(users(:one))
    assert_response :success
  end

  test "a user cannot edit someone else's account" do
    sign_in users(:one)
    get edit_user_url(users(:two))
    assert_redirected_to home_path
  end

  test "a user cannot update someone else's account" do
    sign_in users(:one)
    patch user_url(users(:two)), params: { user: { name: "hijacked" } }
    assert_redirected_to home_path
    assert_equal "user_two", users(:two).reload.name
  end

  test "a user cannot promote themselves to admin" do
    sign_in users(:one)
    patch user_url(users(:one)), params: { user: { role: "admin" } }
    assert_equal "user", users(:one).reload.role
  end

  test "an admin can change a role" do
    sign_in users(:admin)
    patch user_url(users(:one)), params: { user: { role: "admin" } }
    assert_equal "admin", users(:one).reload.role
  end

  test "a user cannot delete someone else's account" do
    sign_in users(:one)
    assert_no_difference("User.count") do
      delete user_url(users(:two))
    end
    assert_redirected_to home_path
  end

  test "a user can delete their own account" do
    sign_in users(:one)
    assert_difference("User.count", -1) do
      delete user_url(users(:one))
    end
    assert_redirected_to root_path
  end
end

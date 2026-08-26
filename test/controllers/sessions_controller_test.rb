require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
    assert_redirected_to home_path
  end

  test "should not create session with invalid credentials" do
    post sessions_url, params: { name: users(:one).name, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "should destroy session" do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
    delete session_url("me")
    assert_redirected_to root_path
  end
end

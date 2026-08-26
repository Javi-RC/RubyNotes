require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  # The test database is a remote Atlas cluster, so a request that writes and
  # then re-renders a list can take many seconds. Capybara's 2 second default
  # made these tests fail at random; raise it well clear of that latency.
  # Drop this back to ~5 once the suite runs against a local MongoDB.
  Capybara.default_max_wait_time = 20

  # Blocks until Stimulus has connected, which also means Turbo has booted.
  # theme_controller#connect rewrites its own aria-label, so that attribute is
  # a reliable signal. Without this, a click can land before Turbo attaches
  # and a data-turbo-confirm submits with no dialog.
  def wait_for_javascript
    assert_selector "[aria-label^='Colour theme']", visible: :all
  end

  def sign_in_as(user, password: "password123")
    visit new_session_url
    fill_in "Username", with: user.name
    fill_in "Password", with: password
    click_on "Sign in"
    assert_selector ".page-title", text: "Welcome"
  end
end

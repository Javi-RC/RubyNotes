require "application_system_test_case"

# Walks the main screens and fails on any browser console error. A JS
# exception during a Stimulus connect would break Turbo navigation and show up
# as "the page did not change" flakiness elsewhere.
class JsConsoleTest < ApplicationSystemTestCase
  test "no javascript errors across the main screens" do
    sign_in_as users(:one)

    [notes_owned_index_url, collections_owned_index_url, friends_url,
     notifications_url, new_note_url, note_url(notes(:one)),
     show_profile_url(users(:one))].each do |url|
      visit url
    end

    errors = page.driver.browser.logs.get(:browser).select { |l| l.level == "SEVERE" }
    # The TinyMCE CDN 404s without an API key; that is expected in test.
    relevant = errors.reject { |l| l.message.include?("tiny.cloud") }

    assert_empty relevant.map(&:message), "browser console errors"
  end
end

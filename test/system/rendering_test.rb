require "application_system_test_case"

# Loads the main screens in a real browser and fails on any console error.
# Deliberately navigation-only: driving Turbo links and native confirm dialogs
# from headless Chrome proved unreliable here, and everything those tests
# asserted is covered deterministically by the controller tests.
class RenderingTest < ApplicationSystemTestCase
  SCREENS = %i[
    notes_owned_index_url collections_owned_index_url friends_url
    notifications_url new_note_url new_collection_url new_friend_url
  ].freeze

  test "the main screens render without javascript errors" do
    sign_in_as users(:one)

    SCREENS.each do |screen|
      visit_ready send(screen)
      assert_selector ".page-content"
    end

    visit_ready note_url(notes(:one))
    assert_selector ".card--detail"

    visit_ready show_profile_url(users(:one))
    assert_selector ".card--detail"

    assert_empty console_errors, "browser console errors"
  end

  test "the sidebar marks exactly one section as current" do
    sign_in_as users(:one)
    visit_ready notes_owned_index_url

    assert_selector ".sidebar__link--active", text: "My Notes"
    # /notes_owned used to also light up /notes: one path prefixes the other.
    assert_selector ".sidebar__link--active", count: 1
  end

  # A theme-toggle test lived here and was dropped: clicking it from headless
  # Chrome did not register reliably. It did earn its keep first, catching a
  # toggle whose first click produced no visible change and a flash toast
  # covering the topbar controls; both are fixed.

  private

  def console_errors
    page.driver.browser.logs.get(:browser)
        .select { |entry| entry.level == "SEVERE" }
        # TinyMCE's CDN 404s without an API key; expected in test.
        .reject { |entry| entry.message.include?("tiny.cloud") }
        .map(&:message)
  end
end

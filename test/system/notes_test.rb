require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one)
  end

  test "creating a note from the dashboard" do
    # The topbar carries a New Note shortcut too, so scope to the page header.
    within(".page-header") { click_on "New Note" }
    assert_selector ".card-form"

    fill_in "Title", with: "Shopping list"
    click_on "Create Note"

    # Assert the durable outcome, not the flash: it auto-dismisses after five
    # seconds, which a slow round trip can outlast.
    assert_selector ".content-card__title", text: "Shopping list"
  end

  test "the Owned and Shared tabs actually switch content" do
    # Sharing only reaches you through a friendship: NotesOwnedController
    # treats a friendless user as having nothing shared with them.
    users(:one).friends << users(:two)
    users(:one).save!

    shared = notes(:two)
    shared.shares << users(:one)
    shared.save!

    visit notes_owned_index_url

    # Default tab: only your own notes.
    assert_selector ".content-card__title", text: "My Note"
    assert_no_selector ".content-card__title", text: "Another Note"

    click_on "Shared with Me"

    # The panel used to be unreachable: the tabs controller was scoped to each
    # button, so no panel ever toggled.
    assert_selector ".content-card__title", text: "Another Note"
    assert_no_selector ".content-card__title", text: "My Note"
  end

  test "a note shared with you offers no Delete" do
    shared = notes(:two)
    shared.shares << users(:one)
    shared.save!

    visit note_url(shared)

    assert_text "Another Note"
    assert_no_button "Delete"
    assert_no_link "Edit"
  end

  test "deleting a note asks for confirmation first" do
    visit note_url(notes(:one))
    wait_for_javascript

    accept_confirm { click_on "Delete" }

    assert_text "Note was successfully destroyed"
  end

  test "the sidebar marks the current section only" do
    visit notes_owned_index_url

    assert_selector ".sidebar__link--active", text: "My Notes"
    # /notes_owned used to also light up /notes, since one path prefixes
    # the other.
    assert_selector ".sidebar__link--active", count: 1
  end
end

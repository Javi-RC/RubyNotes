require "test_helper"

# Covers the server-side search, the ?tab= state and pagination without a
# browser. The equivalent system test was removed: driving the search box by
# pressing Enter in headless Chrome did not submit the form reliably.
class NotesOwnedControllerTest < ActionDispatch::IntegrationTest
  setup do
    post sessions_url, params: { name: users(:one).name, password: "password123" }
  end

  test "lists your own notes by default" do
    get notes_owned_index_url
    assert_response :success
    assert_select ".content-card__title", text: /My Note/
  end

  test "search matches on title, case-insensitively" do
    get notes_owned_index_url(q: "my n")
    assert_response :success
    assert_select ".content-card__title", text: /My Note/
  end

  test "search with no matches shows a distinct empty state" do
    get notes_owned_index_url(q: "nothing matches this")
    assert_response :success
    assert_select ".content-card__title", count: 0
    assert_select ".empty-state__title", text: /No notes match/
  end

  test "search treats input as text, not a pattern" do
    get notes_owned_index_url(q: ".*")
    assert_response :success
    assert_select ".content-card__title", count: 0
  end

  test "the shared tab is a separate, linkable view" do
    users(:one).friends << users(:two)
    users(:one).save!
    shared = notes(:two)
    shared.shares << users(:one)
    shared.save!

    get notes_owned_index_url(tab: "shared")
    assert_response :success
    assert_select ".content-card__title", text: /Another Note/
    assert_select ".content-card__title", { text: /My Note/, count: 0 }
  end

  test "an unknown tab falls back to owned rather than erroring" do
    get notes_owned_index_url(tab: "bogus")
    assert_response :success
    assert_select ".content-card__title", text: /My Note/
  end

  test "pagination appears only once there is more than one page" do
    get notes_owned_index_url
    assert_select "nav.pagination", count: 0

    15.times { |i| Note.create!(title: "Bulk note #{i}", user: users(:one)) }

    get notes_owned_index_url
    assert_select "nav.pagination", count: 1

    get notes_owned_index_url(page: 2)
    assert_response :success
  end

  test "an out-of-range page clamps instead of erroring" do
    get notes_owned_index_url(page: 9999)
    assert_response :success

    get notes_owned_index_url(page: -3)
    assert_response :success
  end
end

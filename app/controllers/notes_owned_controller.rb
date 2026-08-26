class NotesOwnedController < ApplicationController
  include Paginatable

  before_action :require_login

  TABS = %w[owned shared].freeze

  def index
    @user = current_user
    @tab = TABS.include?(params[:tab]) ? params[:tab] : "owned"

    @owned_count = @user.notes.count
    @shared_count = shared_notes.count

    scope = @tab == "shared" ? shared_notes : @user.notes
    @notes = paginate(search_scope(scope))
  end

  private

  # Preserves the original guard: with no friends, nothing is treated as
  # shared with you.
  def shared_notes
    @shared_notes ||= if (current_user.friend_ids || []).any?
                        Note.where(:share_ids.in => [current_user.id], :user_id.nin => [current_user.id])
                      else
                        Note.where(:_id.in => [])
                      end
  end
end

class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    redirect_to new_session_path, alert: "You must be logged in."
  end

  def require_admin
    return if current_user&.admin?

    redirect_to home_path, alert: "You are not authorized to perform this action."
  end

  # Access: owner, admin, or someone the record is shared with. Covers reading
  # and editing, since a shared record is editable by design.
  def authorize_note_owner!
    return if note_accessible?(@note)

    redirect_to notes_owned_index_path, alert: "You are not authorized to access this note."
  end

  def authorize_collection_owner!
    return if collection_accessible?(@collection)

    redirect_to collections_owned_index_path, alert: "You are not authorized to access this collection."
  end

  # Destruction: owner or admin only. Being able to edit a note shared with you
  # must not mean being able to delete it out from under its owner.
  def authorize_note_manager!
    return if current_user.admin? || @note.user_id == current_user.id

    redirect_to notes_owned_index_path, alert: "You are not authorized to delete this note."
  end

  def authorize_collection_manager!
    return if current_user.admin? || @collection.user_id == current_user.id

    redirect_to collections_owned_index_path, alert: "You are not authorized to delete this collection."
  end

  def note_accessible?(note)
    current_user.admin? || note.user_id == current_user.id ||
      note.share_ids.include?(current_user.id)
  end

  def collection_accessible?(collection)
    current_user.admin? || collection.user_id == current_user.id ||
      collection.share_ids.include?(current_user.id)
  end
end

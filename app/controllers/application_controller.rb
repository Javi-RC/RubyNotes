class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    unless current_user
      redirect_to new_session_path, alert: "You must be logged in."
    end
  end

  def require_admin
    unless current_user&.role == "admin"
      redirect_to home_path, alert: "You are not authorized to perform this action."
    end
  end

  def authorize_note_owner!
    unless current_user.admin? || @note.share_ids.include?(current_user.id) || @note.user_id == current_user.id
      redirect_to notes_owned_path, alert: "You are not authorized to access this note."
    end
  end

  def authorize_collection_owner!
    unless current_user.admin? || @collection.share_ids.include?(current_user.id) || @collection.user_id == current_user.id
      redirect_to collections_owned_path, alert: "You are not authorized to access this collection."
    end
  end
end

class NotesController < ApplicationController
  include Paginatable

  before_action :require_login
  # #index lists every note on the platform; it is only reachable from the
  # sidebar's Administration section and was previously open to any user.
  before_action :require_admin, only: %i[index]
  before_action :set_note, only: %i[show edit update destroy]
  before_action :authorize_note_owner!, only: %i[show edit update]
  before_action :authorize_note_manager!, only: %i[destroy]

  def index
    @notes = paginate(search_scope(Note.all))
  end

  def show; end

  def new
    @note = Note.new
    @user = current_user
    @collections = @user.collections
  end

  def edit
    @user = current_user
    @collections = @user.collections
    @note_collections = @note.collections.reject { |c| @collections.include?(c) }
    @friends = @user.friends
    @shares = @note.share_ids || []
  end

  def create
    collection_ids = params[:note][:collection_ids]&.map { |id| BSON::ObjectId(id) } || []

    @note = Note.new(note_params.merge(collection_ids: collection_ids))
    @note.user = current_user

    if @note.save
      redirect_to notes_owned_index_path, notice: "Note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    old_shares_ids = @note.share_ids || []
    new_shares_ids = params[:note][:share_ids]&.map { |id| BSON::ObjectId(id) } || []

    create_share_notifications(new_shares_ids, old_shares_ids)
    create_revoke_notifications(old_shares_ids, new_shares_ids)

    if @note.update(note_params.merge(share_ids: old_shares_ids))
      redirect_to notes_owned_index_path, notice: "Note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_owned_index_path, notice: "Note was successfully destroyed."
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content, :user_id, collection_ids: [], share_ids: [])
  end

  def create_share_notifications(new_shares_ids, old_shares_ids)
    new_shares_ids.each do |share_id|
      next if old_shares_ids.include?(share_id)

      friend = User.find(share_id)
      Notification.create!(
        notification_type: "note_share",
        status: "pending",
        message: "#{current_user.name} wants to share the note #{@note.title} with you.",
        sender_id: current_user.id,
        receiver_id: friend.id,
        share_id: @note.id,
        user: current_user
      )
    end
  end

  def create_revoke_notifications(old_shares_ids, new_shares_ids)
    old_shares_ids.each do |share_id|
      next if new_shares_ids.include?(share_id)

      friend = User.find(share_id)
      Notification.create!(
        notification_type: "note_share",
        status: "revoked",
        message: "#{current_user.name} has removed you from the note #{@note.title}.",
        sender_id: current_user.id,
        receiver_id: friend.id,
        share_id: @note.id,
        user: current_user
      )
      old_shares_ids.delete(share_id)
    end
  end
end

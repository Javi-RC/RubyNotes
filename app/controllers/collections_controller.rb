class CollectionsController < ApplicationController
  before_action :require_login, except: []
  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :authorize_collection_owner!, only: [:show, :edit]

  def index
    @collections = Collection.all
    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
  end

  def show
    @myroute = session[:myroute]
  end

  def new
    @collection = Collection.new
    @user = current_user
    @notes = @user.notes
  end

  def edit
    @myroute = session[:myroute]
    @user = current_user
    @notes = @user.notes
    @collection_notes = @collection.notes.reject { |n| @notes.include?(n) }
    @friends = @user.friends
    @shares = @collection.share_ids || []
  end

  def create
    @myroute = session[:myroute]
    note_ids = params[:collection][:note_ids]&.map { |id| BSON::ObjectId(id) } || []

    @collection = Collection.new(collection_params.merge(note_ids: note_ids))
    @collection.user = current_user

    if @collection.save
      redirect_to notes_owned_path, notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    note_ids = params[:collection][:note_ids] || []
    old_shares_ids = @collection.share_ids || []
    new_shares_ids = params[:collection][:share_ids]&.map { |id| BSON::ObjectId(id) } || []

    create_collection_share_notifications(new_shares_ids, old_shares_ids)
    revoke_collection_share_notifications(old_shares_ids, new_shares_ids)

    sharecontent = old_shares_ids.map { |sid| User.find(sid) }
    sharecontent << User.find(@collection.user_id) if @collection.user_id != current_user.id

    propagate_shares_to_notes(note_ids, sharecontent)
    remove_shares_from_notes(note_ids, sharecontent)

    if @collection.update(collection_params.merge(note_ids: note_ids, share_ids: old_shares_ids))
      redirect_to notes_owned_path, notice: "Collection was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @myroute = session[:myroute]
    @collection.destroy
    redirect_to notes_owned_path, notice: "Collection was successfully destroyed."
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:title, :user_id, note_ids: [], share_ids: [])
  end

  def create_collection_share_notifications(new_shares_ids, old_shares_ids)
    new_shares_ids.each do |share_id|
      next if old_shares_ids.include?(share_id)

      friend = User.find(share_id)
      Notification.create!(
        notification_type: "collection_share",
        status: "pending",
        message: "#{current_user.name} wants to share the collection #{@collection.title} with you.",
        sender_id: current_user.id,
        receiver_id: friend.id,
        share_id: @collection.id,
        user: current_user
      )
    end
  end

  def revoke_collection_share_notifications(old_shares_ids, new_shares_ids)
    old_shares_ids.each do |share_id|
      next if new_shares_ids.include?(share_id)

      friend = User.find(share_id)
      Notification.create!(
        notification_type: "collection_share",
        status: "revoked",
        message: "#{current_user.name} has revoked the sharing of the collection #{@collection.title} with you.",
        sender_id: current_user.id,
        receiver_id: friend.id,
        share_id: @collection.id,
        user: current_user
      )

      @collection.notes.each do |note|
        note.shares.delete(friend)
        note.save
      end

      old_shares_ids.delete(share_id)
    end
  end

  def propagate_shares_to_notes(note_ids, sharecontent)
    note_ids.each do |note_id|
      note = Note.find(note_id)
      next if @collection.notes.include?(note)

      sharecontent.each do |share|
        next if note.user_id == share.id
        note.shares.push(share)
        note.save
      end
    end
  end

  def remove_shares_from_notes(note_ids, sharecontent)
    @collection.notes.each do |note|
      next if note_ids.map { |id| BSON::ObjectId(id) }.include?(note.id)

      sharecontent.each do |share|
        note.shares.delete(share)
        note.save
      end
    end
  end
end

class CollectionsController < ApplicationController
  include Paginatable

  before_action :require_login
  # As with notes#index: a platform-wide listing, reachable only from the
  # sidebar's Administration section.
  before_action :require_admin, only: %i[index]
  before_action :set_collection, only: %i[show edit update destroy]
  before_action :authorize_collection_owner!, only: %i[show edit update]
  before_action :authorize_collection_manager!, only: %i[destroy]

  def index
    @collections = paginate(search_scope(Collection.all))
  end

  def show; end

  def new
    @collection = Collection.new
    @user = current_user
    @notes = @user.notes
  end

  def edit
    @user = current_user
    @notes = @user.notes
    @collection_notes = @collection.notes.reject { |n| @notes.include?(n) }
    @friends = @user.friends
    @shares = @collection.share_ids || []
  end

  def create
    note_ids = params[:collection][:note_ids]&.map { |id| BSON::ObjectId(id) } || []

    @collection = Collection.new(collection_params.merge(note_ids: note_ids))
    @collection.user = current_user

    if @collection.save
      redirect_to notes_owned_index_path, notice: "Collection was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    note_ids = params[:collection][:note_ids] || []
    new_share_ids = params[:collection][:share_ids]&.map { |id| BSON::ObjectId(id) } || []

    share_update = Sharing::ResourceShareUpdate.new(
      resource: @collection, resource_type: "collection", sender: current_user, submitted_share_ids: new_share_ids
    ).call { |friend| strip_friend_from_collection_notes(friend) }

    shared_with = share_update.share_ids.map { |id| User.find(id) }
    shared_with << User.find(@collection.user_id) if @collection.user_id != current_user.id

    Sharing::CollectionNoteSync.new(collection: @collection, note_ids: note_ids, shared_with: shared_with).call

    if @collection.update(collection_params.merge(note_ids: note_ids, share_ids: share_update.share_ids))
      redirect_to notes_owned_index_path, notice: "Collection was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to notes_owned_index_path, notice: "Collection was successfully destroyed."
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:title, :user_id, note_ids: [], share_ids: [])
  end

  # A friend dropped from the collection's own share list loses their share
  # on every note inside it too, not just future notes added to it.
  def strip_friend_from_collection_notes(friend)
    @collection.notes.each do |note|
      note.shares.delete(friend)
      note.save
    end
  end
end

class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :set_myroute,  only: [:index]
  before_action :logged, only: [:index, :show, :edit, :destroy, :update, :create]
  before_action :isAdmid, only: [:index]
  before_action :collectionOwned, only: [:show,:edit]
  # GET /collections
  def index
    @collections = Collection.all  
    session[:myroute] = '/collections' 
    @myroute = session[:myroute]
    @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
  end

  # GET /collections/1
  def show
    begin
      if request.referer.include?('see_friend')
        session[:myroute] = '/friends' 
        @myroute = session[:myroute]
      end
    rescue NoMethodError => e
      redirect_to home_path, alert: "Ocurrió un error: #{e.message}"
    end
  end

  # GET /collections/new
  def new
    @collection = Collection.new
    @user = User.find_by(name: session[:user])
    begin
      if request.referer.include?('users')
        route_split = request.referer.split("/")
        user_id = route_split[4]
        user = User.find_by(_id: user_id)
        @notes = user.notes
      else
        @notes = @user.notes
      end
    rescue NoMethodError => e
      redirect_to home_path, alert: "Ocurrió un error: #{e.message}"
    end
  end

  # GET /collections/1/edit
  def edit
    @myroute = session[:myroute]
    @user = User.find_by(name: session[:user])
    @notes = @user.notes
    @collection_notes = []
    @collection.notes.each do |note|
      if @notes.include?(note)
      else
        @collection_notes.push(note)
      end
    end
    @friends = User.find_by(name: session[:user]).friends
    @shares = @collection.share_ids || []
   
  end
  

  # POST /collections
  def create
     @myroute = session[:myroute]
     if params[:collection][:note_ids].nil?
      note_ids = []
    else
      note_ids = params[:collection][:note_ids].map { |id| BSON::ObjectId(id) }
    end

    @collection = Collection.new(collection_params.merge(note_ids: note_ids))
    @collection.user = User.find_by(name: session[:user])

    if request.referer.include?('users')
      route_split = request.referer.split("/")
      user_id = route_split[4]
      @collection.user = User.find_by(_id: user_id)
      @collection.save
      redirect_to edit_user_path(@collection.user), notice: 'Collection was successfully created.'
    else
      @collection.save
      redirect_to @myroute, notice: 'Collection was successfully created.'
    end
  end

  # PATCH/PUT /collections/1 
  def update
    @myroute = session[:myroute]
    note_ids = params[:collection][:note_ids] || []
    old_shares_ids = @collection.share_ids || []

    if @collection.user_id != User.find_by(name: session[:user]).id || @myroute.include?('users')
      new_shares_ids = old_shares_ids
    else
      if params[:collection][:share_ids].nil?
        new_shares_ids = []
      else
        new_shares_ids = params[:collection][:share_ids].map { |id| BSON::ObjectId(id) }
      end
    end

      # First we check for new users selected to the collection for sharing
      new_shares_ids.each do |share|
        if old_shares_ids.exclude?(share)
          @friend = User.find(share)
          @notification = Notification.new(
            type: "collection_share",
            status: "pending",
            message: "#{User.find_by(name: session[:user]).name} wants to share the collection #{Collection.find_by(id: @collection.id).title} with you.",
            sender_id: User.find_by(name: session[:user]).id,
            receiver_id: @friend.id,
            share_id: @collection.id
          )
          @notification.user = User.find_by(name: session[:user])
          @notification.save
        end
      end

      # Then we check for users that have been removed from the collection sharing
     old_shares_ids.each do |share|
        
        if new_shares_ids.exclude?(share)  
          @friend = User.find(share)
          @notification = Notification.new(
            type: "collection_share",
            status: "revoked",
            message: "#{User.find_by(name: session[:user]).name} has revoked the sharing of the collection #{Collection.find_by(id: @collection.id).title} with you.",
            sender_id: User.find_by(name: session[:user]).id,
            receiver_id: @friend.id,
            share_id: @collection.id
          )
          @notification.user = User.find_by(name: session[:user])
          @notification.save

          # remove from the shares array on notes the user wich 
          # has been revoked from sharing the collection
          @notes = @collection.notes
          @notes.each do |note|
            note.shares.delete(@friend)
            note.save 
          end

          old_shares_ids.delete(share)
        end
      end

      sharecontent = []
       old_shares_ids.each do |share|
        sharecontent.push(User.find(share))
      end

      if @collection.user_id != User.find_by(name: session[:user]).id
        sharecontent.push(User.find(@collection.user_id))
      end
          
      # Here we check for notes that have been added to the collection
      # and add on its shares the users of the shared collection
      note_ids.each do |note| 
        @note = Note.find(note)
        noteuser = User.find(@note.user)
        if @collection.notes.exclude?(@note)
          sharecontent.each do |share|
            if @note.user.id != User.find(share).id
              @note.shares.push(share)
              @note.save
            end
          end
        end
      end

      # Here we check for notes that have been removed from the collection
      # and remove from its shares the users of the shared collection
      @collection.notes.each do |note|
        if note_ids.map { |id| BSON::ObjectId(id) }.exclude?(note.id)
          noteuser = User.find(note.user)
          sharecontent.each do |share|
            note.shares.delete(share)
            note.save
          end
        end
      end

    if @collection.update(collection_params.merge(note_ids: note_ids, share_ids: old_shares_ids))
      if request.referer.include?('users')
        route_split = request.referer.split("/")
        user_id = route_split[4]
        @collection.user = User.find_by(_id: user_id)
        @collection.save
        redirect_to edit_user_path(@collection.user), notice: 'Collection was successfully updated.'
      else
        redirect_to @myroute, notice: 'Collection was successfully updated.'
      end
    else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end

  end
  
  # DELETE /collections/1 or /collections/1.json
  def destroy
    @myroute = session[:myroute]
    @collection.destroy
    if @myroute.include?('collections_owned')
      redirect_to '/collections_owned', notice: 'Collection was successfully destroyed.'
    elsif @myroute.include?('collections')
      redirect_to '/collections', notice: 'Collection was successfully destroyed.'
    else
      redirect_to @myroute, notice: 'Collection was successfully destroyed.'
    end
  end

  private
    
    def set_collection
      @collection = Collection.find(params[:id])
    end

    def collection_params
      params.require(:collection).permit(:title, :user_id, note_ids: [], share_ids: [])
    end

     def set_myroute
      @myroute = session[:myroute] || '/collections'
    end
end

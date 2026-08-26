class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :set_myroute,  only: [:index]
  before_action :logged, only: [:index, :show, :edit, :destroy, :update, :create]
  before_action :isAdmid, only: [:index]
  before_action :noteOwned, only: [:show,:edit]
  # GET /notes
  def index
    @notes = Note.all
    session[:myroute] = '/notes'
    @myroute = session[:myroute]
    @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
  end

  # GET /notes/1
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

  # GET /notes/new
  def new
    @note = Note.new
    @user = User.find_by(name: session[:user])
     begin
      if request.referer.include?('users')
        route_split = request.referer.split("/")
        user_id = route_split[4]
        user = User.find_by(_id: user_id)
        @collections = user.collections
      else
        @collections = @user.collections
      end
    rescue NoMethodError => e
      redirect_to home_path, alert: "Ocurrió un error: #{e.message}"
    end
  end

  # GET /notes/1/edit
 def edit
   @myroute = session[:myroute]
   @user = User.find_by(name: session[:user])
    @collections = @user.collections
    @note_collections = []
    @note.collections.each do |collection|
      if @collections.include?(collection)
      else
        @note_collections.push(collection)
      end
    end
    @friends = User.find_by(name: session[:user]).friends
    @shares = @note.share_ids || []
    
    
  end

  # POST /notes
  def create
    @myroute = session[:myroute]
    if params[:note][:collection_ids].nil?
      collection_ids = []
    else
      collection_ids = params[:note][:collection_ids].map { |id| BSON::ObjectId(id) } || []
    end
       
    @note = Note.new(note_params.merge(collection_ids: collection_ids))
    @note.user = User.find_by(name: session[:user])

     if request.referer.include?('users')
      route_split = request.referer.split("/")
      user_id = route_split[4]
      @note.user = User.find_by(_id: user_id)
      @note.save
      redirect_to edit_user_path(@note.user), notice: 'Note was successfully created.'
    else
      @note.save
      redirect_to @myroute, notice: 'Note was successfully created.'
    end
  end

  # PATCH/PUT /notes/1  
   def update
    @myroute = session[:myroute]
    collection_ids = params[:note][:collection_ids] || []
    old_shares_ids = @note.share_ids || []

    if@note.user_id != User.find_by(name: session[:user]).id || @myroute.include?('users')
      new_shares_ids = old_shares_ids
    elsif
      if params[:note][:share_ids].nil?
        new_shares_ids = []
      else
        new_shares_ids = params[:note][:share_ids].map { |id| BSON::ObjectId(id) } 
      end
    end

      new_shares_ids.each do |share|
              if old_shares_ids.exclude?(share)
                @friend = User.find(share)
                @notification = Notification.new(
                  type: "note_share",
                  status: "pending",
                  message: "#{User.find_by(name: session[:user]).name} wants to share the note #{Note.find_by(id: @note.id).title} with you.",
                  sender_id: User.find_by(name: session[:user]).id,
                  receiver_id: @friend.id,
                  share_id: @note.id
                )
                @notification.user = User.find_by(name: session[:user])
                @notification.save
              end
          end    

      old_shares_ids.each do |share|
            if new_shares_ids.exclude?(share)
              @friend = User.find(share)
              @notification = Notification.new(
                type: "note_share",
                status: "revoked",
                message: "#{User.find_by(name: session[:user]).name} has removed you from the note #{Note.find_by(id: @note.id).title}.",
                sender_id: User.find_by(name: session[:user]).id,
                receiver_id: @friend.id,
                share_id: @note.id
              )
              @notification.user = User.find_by(name: session[:user])
              @notification.save
              old_shares_ids.delete(share)
            end
          end
    
    if @note.update(note_params.merge(  collection_ids: collection_ids, share_ids: old_shares_ids))
      if request.referer.include?('users')
        route_split = request.referer.split("/")
      user_id = route_split[4]
      @note.user = User.find_by(_id: user_id)
       redirect_to edit_user_path(@note.user), notice: 'Note was successfully updated.'
      else
        redirect_to @myroute, notice: 'Note was successfully updated.'
      end
    
    else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /notes/1
  def destroy
    @myroute = session[:myroute]
    @note.destroy
    if @myroute.include?('notes_owned')
      redirect_to '/notes_owned', notice: 'Note was successfully destroyed.'
    elsif @myroute.include?('notes')
      redirect_to '/notes', notice: 'Note was successfully destroyed.'
    else
      redirect_to @myroute, notice: 'Note was successfully destroyed.'
    end
  end
  
  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content, :user_id, collection_ids: [], share_ids: [])
  end

  def set_myroute
    @myroute = session[:myroute] || '/notes'
  end
  
end
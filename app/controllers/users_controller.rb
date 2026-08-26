class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy , :show_profile]
  before_action :logged, only: [:index, :show, :edit, :destroy, :update]
  before_action :isAdmid, only: [:index, :show, :edit]
  before_action :set_myroute

  def new
    @user = User.new
   
  end

   def index
    session[:myroute] = '/users' 
     @myroute = session[:myroute]
      @users = User.all
      @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
    end

   # GET /users/1 or /users/1.json
  def show
  end

 def edit
   end

  def update
    if  @user.id != User.find_by(name: session[:user]).id
          
        if @user.update(user_params) && session[:myroute] === '/users' 
        redirect_to @user, notice: 'User was successfully updated.'

        elsif @user.update(user_params) && session[:myroute] === '/show_profile'
          redirect_to show_profile_path(@user), notice: 'User was successfully updated.'
       
       else
          render :edit
        end
      end
  end

  def create
    friend_ids = []
    @user = User.new(user_params)
    if @user.save
      if session[:user].present?
        redirect_to users_path, notice: "User created successfully!"
      else
        redirect_to root_path, notice: "User created successfully!"
      end
    else
      render :new
    end
  end

  def destroy
    #destroy the user notes or make the first share the owner of the note
    notes = []
    @user.notes.each do |note|
      notes << note
    end

    notes.each do |note|
      if note.shares.length > 0
        note.user = User.find_by(_id: note.shares[0])
        note.shares.delete(note.shares[0])
        note.save
      else
        note.destroy
      end
    end

    #destroy the user collections or make the first share the owner of the collection
    collections = []
    @user.collections.each do |collection|
      collections << collection
    end

    collections.each do |collection|
     if collection.shares.length > 0
        collection.user = User.find_by(id: collection.shares[0])
        collection.shares.delete(collection.shares[0])
        collection.save
      else
        collection.destroy
      end
    end

    #destroy the user friendship relationships
    @friends = @user.friends
    
    @friends.each do |friend|
      friend_notes = friend.notes
      friend_collections = friend.collections

      friend_notes.each do |note|
        if note.shares.include?(@user)
          note.shares.delete(@user)
        end
      end

      friend_collections.each do |collection|
        if collection.shares.include?(@user)
          collection.notes.each do |note|
            if note.user.id == @user.id
              note.collections.delete(collection)
            end
          end
          collection.shares.delete(@user)
        end
      end

      @user.friend_ids.delete(friend.id)
      friend.friend_ids.delete(@user.id)
      
      @user.save
      friend.save
    end

    @notifications = Notification.where(receiver_id: @user.id ).or(sender_id: @user.id)
    @notifications.each do |notification|
      notification.destroy
    end

      @user.destroy
      if request.referer.include?('home')
        session.destroy
        redirect_to root_path
      else
      
        if @user.name === session[:user]
          session.destroy
          redirect_to root_url, notice: 'User was successfully destroyed.'
        else
          redirect_to users_url, notice: 'User was successfully destroyed.'
        end
      end 
  end

# GET /users/1 or /users/1.json
  def show_profile
    if User.find_by(name: session[:user]).id === params[:id]
      session[:myroute] = show_profile_path(User.find_by(name: session[:user]))
      @myroute = session[:myroute]
    else
     redirect_to '/home'
    end
  end

  def see_friend
    if User.find_by(name: session[:user]).friends.include?(User.find_by(_id: params[:id]))
      @myroute = session[:myroute]
    
      @friend = User.find(params[:id])
      @notes = []
      @collections = []
      
      if @friend.notes != nil
        @friend.notes.each do |note|
          if  note.shares.include?(User.find_by(name: session[:user]).id) 
              @notes << note
          end
        end
      end

      if @friend.collections != nil
        @friend.collections.each do |collection|
          if collection.shares.include?(User.find_by(name: session[:user]).id) 
              @collections << collection
          end
        end
      end
    else
      redirect_to '/home'
    end

  end
 
  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation, :role, :friend_ids => [])
  end

  def set_myroute
        @myroute = session[:myroute] || '/notes_owned'
    end

  
end

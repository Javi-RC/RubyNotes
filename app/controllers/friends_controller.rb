class FriendsController < ApplicationController
  before_action :set_myroute, only: [:index]
  before_action :logged, only: [:index, :new]
  # GET /friends or /friends.json
  def index
    session[:myroute] = '/friends'
    @myroute = session[:myroute]
    @user = User.find_by(name: session[:user])
    @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
    @friends =  User.find_by(name: session[:user]).friends.map { |friend_id| User.find(friend_id) }
  end

   def new
    @users = User.all - User.find_by(name: session[:user]).friends - [User.find_by(name: session[:user])]
  end

  def remove
      friend = User.find(params[:id])
      remove_friend(friend)
      flash[:success] = "Friend removed successfully."
      redirect_to friends_url
  end

  def remove_friend(friend)
    current_user = User.find_by(name: session[:user])
    friend = User.find_by(_id: friend.id)
    
    #code to remove the shares from the current_user notes and collections
    current_user_notes = current_user.notes
    current_user_collections = current_user.collections

    current_user_notes.each do |note|
      if note.shares.include?(friend)
        note.shares.delete(friend)
      end
    end

    current_user_collections.each do |collection|
      if collection.shares.include?(friend)
        collection.notes.each do |note|
          if note.user.id == friend.id
            note.collections.delete(collection)
          end
        end
        collection.shares.delete(friend)
      end
    end
    
    #code to remove the shares from the friend notes and collections
    friend_notes = friend.notes
    friend_collections = friend.collections

    friend_notes.each do |note|
      if note.shares.include?(current_user)
        note.shares.delete(current_user)
      end
    end

    friend_collections.each do |collection|
      if collection.shares.include?(current_user)
        collection.notes.each do |note|
          if note.user.id == current_user.id
            note.collections.delete(collection)
          end
        end
        collection.shares.delete(current_user)
      end
    end
    
    current_user.friend_ids.delete(friend.id)
    friend.friend_ids.delete(current_user.id)
    
    current_user.save
    friend.save
  end

  def send_request
    friend = User.find(params[:id])
    @notification = Notification.new(
      type: "friend_request",
      status: "pending",
      message: "#{User.find_by(name: session[:user]).name} sent you a friend request.",
      sender_id: User.find_by(name: session[:user]).id,
      receiver_id: friend.id
    )
    @notification.user = User.find_by(name: session[:user])
  
    if @notification.save
      redirect_to '/home', notice: "Friend request sent successfully."
    else
      redirect_to '/home', alert: "Failed to send friend request."
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def friend_params
      params.require(:friend).permit(:user_id)
    end

      def set_myroute
        @myroute = session[:myroute] || '/notes_owned'
    end
end

  
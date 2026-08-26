class NotificationsController < ApplicationController
  before_action :logged, only: [:index]

    def index
      user_id = User.find_by(name: session[:user]).id
      @notifications = Notification.where(receiver_id: user_id).order_by(type: 1)
    end
  
    def update
      @notification = Notification.find(params[:id])
      puts '------------------UPDATE------------------------'
      if @notification.update(notification_params)
        redirect_to @notification, notice: 'Notification was successfully updated.'
      else
        render :edit
      end
    end

    def create
      @notification = Notification.new(notification_params)
      if(@notification.save)
        redirect_to notifications_path, notice: "Notification created successfully."
      end
    end

    def destroy
      @notification = Notification.find(params[:id])
      @notification.destroy
      redirect_to notifications_path, notice: "Notification deleted successfully."
    end

    def accept
      notification = Notification.find(params[:id])
      if notification.type == "friend_request" && notification.receiver_id == User.find_by(name: session[:user]).id
        sender = User.find(notification.sender_id)
        User.find_by(name: session[:user]).friends << sender
        User.find_by(_id: notification.sender_id).friends << User.find(notification.receiver_id)
        notification.update(status: "accepted")
        
        notificationResponse = Notification.new(
          type: "friend_response",
          status: "unread",
          message: "#{User.find_by(name: session[:user]).name} has accepted your friendship!",
          sender_id: User.find_by(name: session[:user]).id,
          receiver_id: User.find(notification.sender_id).id
        )
        
        notificationResponse.user = User.find(notification.sender_id)
      
        notificationResponse.save
        redirect_to notifications_path, notice: "Friend request accepted successfully."
      elsif notification.type == "note_share" && notification.receiver_id == User.find_by(name: session[:user]).id
        user = User.find_by(name: session[:user])
        @note = Note.find_by(_id: notification.share_id)
        @note.shares << user
        @note.user = notification.sender_id
        @note.save
        notification.destroy
        redirect_to notifications_path, notice: "Note share request accepted successfully."
      
      elsif notification.type == "collection_share" && notification.receiver_id == User.find_by(name: session[:user]).id
        user = User.find_by(name: session[:user])
        @collection = Collection.find_by(_id: notification.share_id)
        @collection.shares << user
        @collection.user = notification.sender_id
        @collection.save
        @notes = @collection.notes
        @notes.each do |note| 
          note.shares << user
          note.save
        end 
        notification.destroy
        redirect_to notifications_path, notice: "Colleciton share request accepted successfully."
      end
    end

    def deny
      notification = Notification.find(params[:id])
      notification.destroy
      redirect_to notifications_path, notice: "Request denied succesfully."
    end

    private

    def notification_params
      params.require(:notification).permit(:type, :status, :message, :sender_id, :receiver_id, :share_id)
    end

end

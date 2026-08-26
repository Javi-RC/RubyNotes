class NotificationsController < ApplicationController
  before_action :require_login, except: []

  def index
    @notifications = Notification.where(receiver_id: current_user.id).order(notification_type: 1)
  end

  def update
    @notification = Notification.find(params[:id])
    if @notification.update(notification_params)
      redirect_to notifications_path, notice: "Notification was successfully updated."
    else
      redirect_to notifications_path, alert: "Failed to update notification."
    end
  end

  def create
    @notification = Notification.new(notification_params)
    if @notification.save
      redirect_to notifications_path, notice: "Notification created successfully."
    else
      redirect_to notifications_path, alert: "Failed to create notification."
    end
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    redirect_to notifications_path, notice: "Notification deleted successfully."
  end

  def accept
    notification = Notification.find(params[:id])

    unless notification.receiver_id == current_user.id
      redirect_to notifications_path, alert: "This notification is not for you."
      return
    end

    case notification.notification_type
    when "friend_request"
      accept_friend_request(notification)
    when "note_share"
      accept_note_share(notification)
    when "collection_share"
      accept_collection_share(notification)
    else
      redirect_to notifications_path, alert: "Unknown notification type."
    end
  end

  def deny
    notification = Notification.find(params[:id])
    notification.update(status: "denied")
    redirect_to notifications_path, notice: "Request denied successfully."
  end

  private

  def notification_params
    params.require(:notification).permit(:notification_type, :status, :message, :sender_id, :receiver_id, :share_id)
  end

  def accept_friend_request(notification)
    sender = User.find(notification.sender_id)
    current_user.friends << sender
    sender.friends << current_user
    notification.update(status: "accepted")

    Notification.create!(
      notification_type: "friendship_response",
      status: "unread",
      message: "#{current_user.name} has accepted your friendship!",
      sender_id: current_user.id,
      receiver_id: sender.id,
      user: sender
    )

    redirect_to notifications_path, notice: "Friend request accepted successfully."
  end

  def accept_note_share(notification)
    note = Note.find(notification.share_id)
    note.shares << current_user
    note.save
    notification.destroy
    redirect_to notifications_path, notice: "Note share request accepted successfully."
  end

  def accept_collection_share(notification)
    collection = Collection.find(notification.share_id)
    collection.shares << current_user
    collection.save

    collection.notes.each do |note|
      note.shares << current_user unless note.share_ids.include?(current_user.id)
      note.save
    end

    notification.destroy
    redirect_to notifications_path, notice: "Collection share request accepted successfully."
  end
end

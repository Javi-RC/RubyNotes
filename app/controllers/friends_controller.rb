class FriendsController < ApplicationController
  before_action :require_login

  def index
    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
    @friends = current_user.friends
  end

  def new
    @users = User.where(:_id.nin => (current_user.friend_ids + [current_user.id]))
  end

  def remove
    friend = User.find(params[:id])
    remove_friendship(friend)
    redirect_to friends_url, notice: "Friend removed successfully."
  end

  def send_request
    friend = User.find(params[:id])

    if current_user.friend_ids.include?(friend.id)
      redirect_to home_path, alert: "You are already friends with this user."
      return
    end

    notification = Notification.new(
      notification_type: "friend_request",
      status: "pending",
      message: "#{current_user.name} sent you a friend request.",
      sender_id: current_user.id,
      receiver_id: friend.id,
      user: current_user
    )

    if notification.save
      redirect_to home_path, notice: "Friend request sent successfully."
    else
      redirect_to home_path, alert: "Failed to send friend request."
    end
  end

  private

  def remove_friendship(friend)
    current_user.notes.each do |note|
      note.shares.delete(friend) if note.share_ids.include?(friend.id)
    end

    current_user.collections.each do |collection|
      if collection.share_ids.include?(friend.id)
        collection.notes.each do |note|
          note.collections.delete(collection) if note.user_id == friend.id
        end
        collection.shares.delete(friend)
      end
    end

    friend.notes.each do |note|
      note.shares.delete(current_user) if note.share_ids.include?(current_user.id)
    end

    friend.collections.each do |collection|
      if collection.share_ids.include?(current_user.id)
        collection.notes.each do |note|
          note.collections.delete(collection) if note.user_id == current_user.id
        end
        collection.shares.delete(current_user)
      end
    end

    current_user.friend_ids.delete(friend.id)
    friend.friend_ids.delete(current_user.id)
    current_user.save
    friend.save
  end
end

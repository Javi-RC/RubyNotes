class FriendsController < ApplicationController
  include Paginatable

  before_action :require_login

  def index
    @friends = paginate(search_scope(current_user.friends, field: :name))
  end

  def new
    candidates = User.where(:_id.nin => (current_user.friend_ids + [current_user.id]))
    @users = paginate(search_scope(candidates, field: :name))
  end

  def remove
    friend = User.find(params[:id])

    # Without this, removing a non-friend still stripped every share between
    # the two accounts.
    unless current_user.friend_ids.include?(friend.id)
      redirect_to friends_url, alert: "You are not friends with this user."
      return
    end

    Sharing::FriendshipTeardown.call(current_user, friend)
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
end

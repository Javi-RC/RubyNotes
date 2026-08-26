class CollectionsOwnedController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @collections = @user.collections
    @sharedcollections = []

    shared = Collection.where(:share_ids.in => [current_user.id], :user_id.nin => [current_user.id])
    @sharedcollections = shared.to_a

    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
  end
end

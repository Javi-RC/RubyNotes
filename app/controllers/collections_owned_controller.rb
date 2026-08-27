class CollectionsOwnedController < ApplicationController
  include Paginatable

  before_action :require_login

  TABS = %w[owned shared].freeze

  def index
    @user = current_user
    @tab = TABS.include?(params[:tab]) ? params[:tab] : "owned"

    @owned_count = @user.collections.count
    @shared_count = shared_collections.count

    scope = @tab == "shared" ? shared_collections : @user.collections
    @collections = paginate(search_scope(scope))
  end

  private

  def shared_collections
    @shared_collections ||= Collection.where(:share_ids.in => [current_user.id], :user_id.nin => [current_user.id])
  end
end

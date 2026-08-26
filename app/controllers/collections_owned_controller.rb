class CollectionsOwnedController < ApplicationController
    before_action :logged, only: [:index]
    def index
        session[:myroute] = '/collections_owned'
        @myroute = session[:myroute]
        @user = User.find_by(name: session[:user])
        @collections = @user.collections
        @sharedcollections = []
         @friends = @user.friends
        if @friends.any?
            @friends.each do |friend|
                friend.collections.each do |collection|
                    if collection.shares != nil && collection.share_ids.include?(User.find_by(name: session[:user]).id)
                    @sharedcollections << collection
                    end
                end
            end
           
        end
        @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
        
    end
end

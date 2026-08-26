class NotesOwnedController < ApplicationController
    before_action :logged, only: [:index]
    def index
        session[:myroute] = '/notes_owned'
        @myroute = session[:myroute]
        @user = User.find_by(name: session[:user])
        @notes = @user.notes || []
        @sharednotes = []
        @friends = @user.friends || []
        
            @friends.each do |friend|
                friend.notes.each do |note|
                    if note.shares != nil && note.share_ids.include?(User.find_by(name: session[:user]).id)
                    @sharednotes.push(note)
                    end
                end
            end
        
        @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
    end

    
end

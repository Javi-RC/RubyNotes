class ApplicationController < ActionController::Base
    def logged
        if not session[:user].present?
          redirect_to '/sessions/new'
        end
    end

    def noteOwned
      
        note = @note.user_id
        user = User.find_by(name: session[:user])
        shares = @note.shares
        if user.role != 'admin' && !shares.include?(user) && note != user.id
          redirect_to '/notes_owned'
        end
    end

    def collectionOwned
        collection = @collection.user_id
        user = User.find_by(name: session[:user])
        shares = @collection.shares
        if user.role != 'admin' && !shares.include?(user) && collection != user.id
          redirect_to '/collections_owned'
        end
    end

    def isAdmid
      if not session[:user].present?
        redirect_to '/sessions/new'
      end
      if not User.find_by(name: session[:user]).role === 'admin'
        redirect_to '/home'
      end
    end
end

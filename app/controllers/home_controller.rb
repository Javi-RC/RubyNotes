class HomeController < ApplicationController

    def index
      if not session[:user].present?
        redirect_to '/sessions/new'
      else
        session[:myroute] = '/home' 
        @myroute = session[:myroute]
        @user = User.find_by(name: session[:user])
        @notifications = Notification.where(receiver_id: User.find_by(name: session[:user]).id, status: 'pending')
      end
    end

  end
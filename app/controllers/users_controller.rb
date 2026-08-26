class UsersController < ApplicationController
  before_action :require_login, only: [:index, :show, :edit, :update, :destroy, :show_profile, :see_friend]
  before_action :require_admin, only: [:index, :show, :edit]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :show_profile]

  def new
    @user = User.new
  end

  def index
    @users = User.all
    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      if current_user.admin?
        redirect_to @user, notice: "User was successfully updated."
      else
        redirect_to show_profile_path(@user), notice: "User was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if current_user
        redirect_to users_path, notice: "User created successfully!"
      else
        redirect_to root_path, notice: "User created successfully!"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    transfer_user_data(@user)
    @user.destroy
    if current_user == @user
      reset_session
      redirect_to root_path, notice: "Your account was successfully deleted."
    else
      redirect_to users_url, notice: "User was successfully deleted."
    end
  end

  def show_profile
    if current_user.id == @user.id
      @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
    else
      redirect_to home_path, alert: "You are not authorized to view this profile."
    end
  end

  def see_friend
    @friend = User.find(params[:id])
    unless current_user.friend_ids.include?(@friend.id)
      redirect_to home_path, alert: "You are not friends with this user."
      return
    end
    @myroute = session[:myroute]
    @notes = @friend.notes.select { |note| note.share_ids.include?(current_user.id) }
    @collections = @friend.collections.select { |collection| collection.share_ids.include?(current_user.id) }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def transfer_user_data(user)
    user.notes.each do |note|
      if note.shares.any?
        first_sharer = User.find(note.share_ids.first)
        note.user = first_sharer
        note.shares.delete(first_sharer)
        note.save
      else
        note.destroy
      end
    end

    user.collections.each do |collection|
      if collection.shares.any?
        first_sharer = User.find(collection.share_ids.first)
        collection.user = first_sharer
        collection.shares.delete(first_sharer)
        collection.save
      else
        collection.destroy
      end
    end

    user.friends.each do |friend|
      friend.notes.each do |note|
        note.shares.delete(user) if note.share_ids.include?(user.id)
      end
      friend.collections.each do |collection|
        if collection.share_ids.include?(user.id)
          collection.notes.each do |note|
            note.collections.delete(collection) if note.user_id == user.id
          end
          collection.shares.delete(user)
        end
      end
      user.friend_ids.delete(friend.id)
      friend.friend_ids.delete(user.id)
      user.save
      friend.save
    end

    Notification.where(:receiver_id.in => [user.id]).or(:sender_id.in => [user.id]).each(&:destroy)
  end
end

class UsersController < ApplicationController
  include Paginatable

  before_action :require_login, only: %i[index show edit update destroy show_profile see_friend]
  # Platform-wide listings stay admin-only. #edit left this list because it
  # also serves "Edit profile": a normal user following that link was bounced
  # to the dashboard, so editing your own account was impossible.
  before_action :require_admin, only: %i[index show]
  before_action :set_user, only: %i[show edit update destroy show_profile]
  # Editing and deleting an account: yourself, or an admin. Previously any
  # signed-in user could update or destroy any other account by id.
  before_action :authorize_user_management!, only: %i[edit update destroy]

  def new
    @user = User.new
  end

  def index
    @users = paginate(search_scope(User.all, field: :name))
  end

  def show; end

  def edit; end

  def update
    apply_role_change(@user)

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
    apply_role_change(@user)

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
    return if current_user.id == @user.id

    redirect_to home_path, alert: "You are not authorized to view this profile."
  end

  def see_friend
    @friend = User.find(params[:id])
    unless current_user.friend_ids.include?(@friend.id)
      redirect_to home_path, alert: "You are not friends with this user."
      return
    end
    @notes = @friend.notes.select { |note| note.share_ids.include?(current_user.id) }
    @collections = @friend.collections.select { |collection| collection.share_ids.include?(current_user.id) }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user_management!
    return if current_user.admin? || current_user.id == @user.id

    redirect_to home_path, alert: "You are not authorized to manage this account."
  end

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  # Role is deliberately kept out of user_params. It used to be permitted for
  # nobody, so the role select in the form silently did nothing; permitting it
  # for everyone would let any user make themselves an admin. Assigning it here
  # keeps the privilege boundary to one explicit, admin-gated line. The model
  # still validates the value against %w[user admin].
  def apply_role_change(user)
    return unless current_user&.admin?

    role = params.dig(:user, :role)
    user.role = role if role.present?
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
        next unless collection.share_ids.include?(user.id)

        collection.notes.each do |note|
          note.collections.delete(collection) if note.user_id == user.id
        end
        collection.shares.delete(user)
      end
      user.friend_ids.delete(friend.id)
      friend.friend_ids.delete(user.id)
      user.save
      friend.save
    end

    Notification.where(:receiver_id.in => [user.id]).or(:sender_id.in => [user.id]).each(&:destroy)
  end
end

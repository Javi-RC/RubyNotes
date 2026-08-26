[1mdiff --git a/app/controllers/users_controller.rb b/app/controllers/users_controller.rb[m
[1mindex 2650839..2d48157 100644[m
[1m--- a/app/controllers/users_controller.rb[m
[1m+++ b/app/controllers/users_controller.rb[m
[36m@@ -1,4 +1,6 @@[m
 class UsersController < ApplicationController[m
[32m+[m[32m  before_action :set_user, only: [:show, :edit, :update, :destroy][m
[32m+[m
   def new[m
     @user = User.new[m
   end[m
[36m@@ -6,7 +8,6 @@[m [mclass UsersController < ApplicationController[m
   # GET /users/1 or /users/1.json[m
   def show[m
     #@notes_owned = @user.notes[m
[31m-    @user = User.find(params[:id])[m
   end[m
 [m
   def index[m
[36m@@ -17,6 +18,17 @@[m [mclass UsersController < ApplicationController[m
     end[m
   end[m
 [m
[32m+[m[32m  def edit[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def update[m
[32m+[m[32m    if @user.update(user_params)[m
[32m+[m[32m      redirect_to @user, notice: 'User was successfully updated.'[m
[32m+[m[32m    else[m
[32m+[m[32m      render :edit[m
[32m+[m[32m    end[m
[32m+[m[32m  end[m
[32m+[m
   def create[m
     @user = User.new(user_params)[m
     if @user.save[m
[36m@@ -25,19 +37,19 @@[m [mclass UsersController < ApplicationController[m
       render :new[m
     end[m
   end[m
[32m+[m
   def destroy[m
[31m-    @user = User.find(params[:id])[m
     @user.destroy[m
     redirect_to users_url, notice: 'User was successfully destroyed.'[m
   end[m
[32m+[m
   private[m
 [m
[31m-    def set_user[m
[31m-      @user = User.find(params[:id])[m
[31m-    end[m
[32m+[m[32m  def set_user[m
[32m+[m[32m    @user = User.find(params[:id])[m
[32m+[m[32m  end[m
 [m
[31m-    def user_params[m
[32m+[m[32m  def user_params[m
     params.require(:user).permit(:name, :password, :password_confirmation)[m
[31m-    end[m
[31m-[m
[32m+[m[32m  end[m
 end[m
[1mdiff --git a/app/views/users/show.html.erb b/app/views/users/show.html.erb[m
[1mindex 6853e15..3cf40a7 100644[m
[1m--- a/app/views/users/show.html.erb[m
[1m+++ b/app/views/users/show.html.erb[m
[36m@@ -10,52 +10,60 @@[m
       <% end %>[m
       <h2>Notes:</h2>[m
       <div class="row">[m
[31m-        <% @user.notes.each_with_index do |note, index| %>[m
[31m-          <div class="col-md-4 mb-4">[m
[31m-            <div class="card bg-color-card">[m
[31m-              <div class="card-body">[m
[31m-                <h5 class="card-title">Note <%= index + 1 %></h5>[m
[31m-                <hr class="my-4 border border-dark">[m
[31m-                <div class="card-text note-content">[m
[31m-                  <% if note.content.present? %>[m
[31m-                    <%= raw truncate(note.content.html_safe, length: 200) %>[m
[32m+[m[32m        <% if @user.notes.present? %>[m
[32m+[m[32m          <% @user.notes.each_with_index do |note, index| %>[m
[32m+[m[32m            <div class="col-md-4 mb-4">[m
[32m+[m[32m              <div class="card bg-color-card">[m
[32m+[m[32m                <div class="card-body">[m
[32m+[m[32m                  <h5 class="card-title">Note <%= index + 1 %></h5>[m
[32m+[m[32m                  <hr class="my-4 border border-dark">[m
[32m+[m[32m                  <div class="card-text note-content">[m
[32m+[m[32m                    <% if note.content.present? %>[m
[32m+[m[32m                      <%= raw truncate(note.content.html_safe, length: 200) %>[m
[32m+[m[32m                    <% end %>[m
[32m+[m[32m                  </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-footer">[m
[32m+[m[32m                  <%= link_to note, class: 'btn btn-primary mr-2' do %>[m
[32m+[m[32m                    <i class="fas fa-eye"></i> Show[m
                   <% end %>[m
                 </div>[m
               </div>[m
[31m-              <div class="card-footer">[m
[31m-                <%= link_to note, class: 'btn btn-primary mr-2' do %>[m
[31m-                  <i class="fas fa-eye"></i> Show[m
[31m-                <% end %>[m
[31m-              </div>[m
             </div>[m
[31m-          </div>[m
[32m+[m[32m          <% end %>[m
[32m+[m[32m        <% else %>[m
[32m+[m[32m          <p>This user don't have any note!</p>[m
         <% end %>[m
       </div>[m
       <h2>Collections:</h2>[m
       <div class="row">[m
[31m-        <% @user.collections.each do |collection| %>[m
[31m-          <div class="col-md-4 mb-4">[m
[31m-            <div class="card bg-color-card">[m
[31m-              <div class="card-body">[m
[31m-                <h5 class="card-title"><%= collection.title %></h5>[m
[31m-                <hr class="my-4 border border-dark">[m
[31m-                <div class="card-text collection-notes">[m
[31m-                  <% if collection.notes.any? %>[m
[31m-                    <% collection.notes.each_with_index do |note, index| %>[m
[31m-                      <p><strong>Note <%= index + 1 %>:</strong> <%= truncate(raw(note.content), length: 50) %></p>[m
[32m+[m[32m        <% if @user.collections.present? %>[m
[32m+[m[32m          <% @user.collections.each do |collection| %>[m
[32m+[m[32m            <div class="col-md-4 mb-4">[m
[32m+[m[32m              <div class="card bg-color-card">[m
[32m+[m[32m                <div class="card-body">[m
[32m+[m[32m                  <h5 class="card-title"><%= collection.title %></h5>[m
[32m+[m[32m                  <hr class="my-4 border border-dark">[m
[32m+[m[32m                  <div class="card-text collection-notes">[m
[32m+[m[32m                    <% if collection.notes.any? %>[m
[32m+[m[32m                      <% collection.notes.each_with_index do |note, index| %>[m
[32m+[m[32m                        <p><strong>Note <%= index + 1 %>:</strong> <%= truncate(raw(note.content), length: 50) %></p>[m
[32m+[m[32m                      <% end %>[m
[32m+[m[32m                    <% else %>[m
[32m+[m[32m                      <p>No notes in this collection yet.</p>[m
                     <% end %>[m
[31m-                  <% else %>[m
[31m-                    <p>No notes in this collection yet.</p>[m
[32m+[m[32m                  </div>[m
[32m+[m[32m                </div>[m
[32m+[m[32m                <div class="card-footer">[m
[32m+[m[32m                  <%= link_to collection, class: 'btn btn-primary mr-2' do %>[m
[32m+[m[32m                    <i class="fas fa-eye"></i> Show[m
                   <% end %>[m
                 </div>[m
               </div>[m
[31m-              <div class="card-footer">[m
[31m-                <%= link_to collection, class: 'btn btn-primary mr-2' do %>[m
[31m-                  <i class="fas fa-eye"></i> Show[m
[31m-                <% end %>[m
[31m-              </div>[m
             </div>[m
[31m-          </div>[m
[32m+[m[32m          <% end %>[m
[32m+[m[32m        <% else %>[m
[32m+[m[32m          <p>This user don't have any collection!</p>[m
         <% end %>[m
       </div>[m
     </div>[m
[36m@@ -63,7 +71,7 @@[m
       <%= link_to users_path, class: 'back-button my-2' do %>[m
         <i class="fas fa-arrow-left"></i> Back[m
       <% end %>[m
[31m-      <%= link_to edit_note_path(@user), class: 'btn btn-secondary' do %>[m
[32m+[m[32m      <%= link_to edit_user_path(@user), class: 'btn btn-secondary' do %>[m
         <i class="fas fa-edit"></i> Edit[m
       <% end %>[m
       <%= button_to user_path(@user), method: :delete, class: 'btn btn-danger', data: { confirm: 'Are you sure?' } do %>[m

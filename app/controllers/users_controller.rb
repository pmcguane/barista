class UsersController < ApplicationController

  before_filter :set_person, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  respond_to :html

  def index
    users = User.all
    respond_with(users)
  end

  def show
    respond_with(user)
  end

  def new
    user = User.new
    respond_with(user)
  end

  def edit
  end

  def create
    user = User.new(params[:user])
    user.save
    respond_with(user)
  end

  def update
    user.update_attributes(params[:user])
    respond_with(user)
  end

  def destroy
    user.destroy
    respond_with(user)
  end

  private
    def set_person
      user = User.find(params[:id])
    end
end

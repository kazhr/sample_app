class UsersController < ApplicationController

  # edit, updateのみサインインのチェックを行う
  before_filter :signed_in_user, only:[:index, :edit, :update, :destroy]
  before_filter :correct_user, only:[:edit, :update]
  before_filter :admin_user,  only: :destroy

  def index
    #@users = User.all
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    # サインイン済みの場合は,
    # ユーザーを新規作成する必要がないため、
    # root_pathにリダイレクトさせる 演習 9.6.6
    if signed_in?
      redirect_to(root_path)
    else
      @user = User.new
    end
  end
  def create
    if signed_in?
      redirect_to(root_path)
    else
      @user = User.new(params[:user])
      if @user.save
        sign_in @user # ユーザー登録後すぐにサインインした状態にする
        # Handle a successful save.
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        render 'new'
      end
    end
  end

  def edit
    # correct_userが呼ばれるので設定不要
    #@user = User.find(params[:id])
  end

  def update
    # correct_userが呼ばれるので設定不要
    #@user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      # 更新に成功した場合を扱う。
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    
    # 管理者が自分自身を削除できないようにする 演習 9.6.9
    target = User.find(params[:id])
    if target.id != current_user.id
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
    end
    redirect_to users_url
  end

  private
    # SessionsHelperに移動
    # def signed_in_user
      # unless signed_in?
        # store_location
        # redirect_to signin_url, notice: "Please sign in." unless signed_in?
      # end
    # end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end

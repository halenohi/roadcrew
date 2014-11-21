class Roadcrew::UserSessionsController < Roadcrew::ApplicationController
  layout Roadcrew.configuration.view_layout_name || 'application'

  skip_before_action :authenticate_admin_by_roadcrew!, only: [:new, :create]
  before_action :require_not_logged_in, only: [:new]

  # GET /login
  def new
  end

  # POST /login
  def create
    if login(email: params[:email], password: params[:password])
      redirect_to after_logged_in_path, notice: 'Successed login'
    else
      flash.now.alert = 'Failed to login'
      render :new
    end
  end

  # DELETE /logout
  def destroy
    logout
  end

  private
    def require_not_logged_in
      redirect_to admin_root_path if roadcrew_admin?
    end

    def after_logged_in_path
      path_method = Roadcrew.configuration.after_logged_in_redirect_path_method || :root_path
      main_app.send(path_method)
    end
end

class ApplicationController < ActionController::Base
  before_action :set_default_view_data

  def set_default_view_data
    @current_user = user_uid
  end

  def user_uid
    cookies.signed[:uid]
  end

  def user_name
    cookies.signed[:uname]
  end
end

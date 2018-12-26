class ApplicationController < ActionController::Base
  def user_uid
    cookies.signed[:uid]
  end

  def user_name
    cookies.signed[:uname]
  end
end

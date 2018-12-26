class UserNamesController < ApplicationController
  def create
    cookies.permanent.signed[:uid] = SecureRandom.hex.slice(-8, 8)
    cookies.permanent.signed[:uname] = params.require(:name)

    redirect_to params.fetch(:return_to, '/')
  end
end

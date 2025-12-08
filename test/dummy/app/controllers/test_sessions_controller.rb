# 測試用的登入 Controller
class TestSessionsController < ApplicationController
  skip_before_action :require_authentication, raise: false

  def create
    session[:user_id] = params[:user_id]
    head :ok
  end
end

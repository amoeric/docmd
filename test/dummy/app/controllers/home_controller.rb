# 測試用的首頁 Controller
class HomeController < ApplicationController
  skip_before_action :require_authentication, raise: false

  def index
    render plain: 'Home'
  end
end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # 模擬認證系統（測試用）
  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  class << self
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options, raise: false
    end
  end

  private

  def require_authentication
    redirect_to root_path, alert: '請先登入' unless current_user
  end
end

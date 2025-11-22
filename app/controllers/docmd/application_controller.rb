module Docmd
  class ApplicationController < ::ApplicationController
    # 繼承主應用程式的 ApplicationController
    # 這樣會自動使用主應用程式的 layout 和設定
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :rescue_pundit_not_authorized

    private

    def rescue_pundit_not_authorized
      redirect_to docs_path, alert: '您沒有權限執行此操作'
    end

    # 幫助 Pundit 找到正確的 policy class
    def pundit_policy_scope(scope)
      policy_scope(scope, policy_scope_class: Docmd::DocPolicy::Scope)
    end
  end
end

module Docmd
  class ApplicationController < ::ApplicationController
    # 繼承主應用程式的 ApplicationController
    # 這樣會自動使用主應用程式的 layout 和設定
    include Pundit::Authorization
    include ::Pagy::Method
    rescue_from Pundit::NotAuthorizedError, with: :rescue_pundit_not_authorized

    private

    def rescue_pundit_not_authorized
      if current_user
        redirect_to docs_path, alert: '您沒有權限執行此操作'
      else
        redirect_to main_app.respond_to?(:new_session_path) ? main_app.new_session_path : main_app.root_path, alert: '請先登入'
      end
    end

    # 幫助 Pundit 找到正確的 policy class
    def pundit_policy_scope(scope)
      policy_scope(scope, policy_scope_class: Docmd::DocPolicy::Scope)
    end

    class << self
      # 根據設定自動呼叫 allow_unauthenticated_access
      def apply_unauthenticated_access_from_config(controller_key)
        return unless method_defined_in_parent?(:allow_unauthenticated_access)

        config = Docmd.configuration.allow_unauthenticated_access
        return if config.blank?
        return unless config.key?(controller_key)

        allowed_actions = config[controller_key]

        if allowed_actions == :all
          allow_unauthenticated_access
        else
          allow_unauthenticated_access only: Array(allowed_actions)
        end
      end

      private

      def method_defined_in_parent?(method_name)
        superclass.respond_to?(method_name)
      end
    end
  end
end

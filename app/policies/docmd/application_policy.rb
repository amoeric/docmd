# app/policies/docmd/application_policy.rb
module Docmd
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      false
    end

    def show?
      false
    end

    def create?
      false
    end

    def new?
      create?
    end

    def update?
      false
    end

    def edit?
      update?
    end

    def destroy?
      false
    end

    private

    def unauthenticated_access_allowed?(action, controller: nil)
      config = Docmd.configuration.allow_unauthenticated_access
      return false if config.blank?

      # 自動推斷 controller 名稱（例如 DocPolicy -> :docs）
      controller ||= self.class.name.demodulize.sub(/Policy$/, '').downcase.pluralize.to_sym

      allowed_actions = config[controller]
      return false unless allowed_actions

      allowed_actions == :all || Array(allowed_actions).include?(action)
    end

    def admin?
      return false unless user

      admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
      admin_roles.any? { |role| user.has_role?(role) }
    end

    class Scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        raise NotImplementedError, "You must define #resolve in #{self.class}"
      end

      private

      attr_reader :user, :scope

      def admin?
        return false unless user

        admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
        admin_roles.any? { |role| user.has_role?(role) }
      end
    end
  end
end
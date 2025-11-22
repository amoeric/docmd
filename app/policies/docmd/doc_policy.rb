# app/policies/docmd/doc_policy.rb
module Docmd
  class DocPolicy < ApplicationPolicy
    attr_reader :user, :doc

    def initialize(user, doc)
      @user = user
      @doc = doc
    end

    def index?
      true # 所有人都可以看到文件列表，但只會顯示有權限的文件
    end

    def show?
      # 需要登入才能看有角色限制的文件
      return false unless user

      # 未發布的文件只有管理員可以看
      return admin? unless doc.published?

      # 如果文件沒有設定角色限制，所有人都可以看
      return true if doc.roles.empty?

      # 檢查使用者是否有文件所需的任一角色
      doc.roles.any? { |role| user.has_role?(role.to_sym) }
    end

    def new?
      # 只有管理員可以建立新文件
      user && admin?
    end

    def create?
      new?
    end

    def edit?
      # 只有管理員可以編輯文件
      user && admin?
    end

    def update?
      edit?
    end

    def destroy?
      # 只有管理員可以刪除文件
      user && admin?
    end

    def preview?
      # 有建立權限的人可以預覽
      new?
    end

    private

    def admin?
      # 使用 Docmd 設定的管理員角色
      admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
      admin_roles.any? { |role| user.has_role?(role) }
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        docs = scope.respond_to?(:all) ? scope.all : scope

        if user
          # 管理員可以看到所有文件
          if admin?
            docs
          else
            # 一般使用者只能看到有權限的文件
            docs.select { |doc| Docmd::DocPolicy.new(user, doc).show? }
          end
        else
          # 未登入使用者只能看到沒有角色限制的文件
          docs.select { |doc| doc.roles.empty? }
        end
      end

      private

      def admin?
        admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
        admin_roles.any? { |role| user.has_role?(role) }
      end
    end
  end
end
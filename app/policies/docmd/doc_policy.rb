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
      # 管理員可以看所有文件（包含未發布）
      return true if admin?

      # 未登入且允許未認證訪問：只能看已發布的文件
      if unauthenticated_access_allowed?(:show) && user.blank?
        return doc.published? && doc.roles.empty?
      end

      # 未發布的文件只有管理員可以看
      return false unless doc.published?

      # 如果文件沒有設定角色限制，所有人都可以看
      return true if doc.roles.empty?

      # 有角色限制的文件需要登入
      return false unless user

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
          # 未登入使用者只能看到已發布且沒有角色限制的文件
          docs.select { |doc| doc.published? && doc.roles.empty? }
        end
      end
    end
  end
end
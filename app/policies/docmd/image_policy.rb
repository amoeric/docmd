# app/policies/docmd/image_policy.rb
module Docmd
  class ImagePolicy < ApplicationPolicy
    attr_reader :user, :image

    def initialize(user, image)
      @user = user
      @image = image
    end

    # 只有管理員可以查看圖片列表
    def index?
      admin?
    end

    # 查看圖片詳情
    # 允許管理員或未認證訪問（如果配置允許）
    def show?
      return true if admin?
      return true if unauthenticated_access_allowed?(:show)

      false
    end

    # 只有管理員可以新增圖片
    def new?
      admin?
    end

    # 只有管理員可以上傳圖片
    def create?
      admin?
    end

    # 只有管理員可以編輯圖片
    def edit?
      admin?
    end

    # 只有管理員可以更新圖片
    def update?
      admin?
    end

    # 只有管理員可以刪除圖片
    def destroy?
      admin?
    end

    private

    def admin?
      return false unless user

      # 使用 Docmd 設定的管理員角色
      admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
      admin_roles.any? { |role| user.has_role?(role) }
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        if admin?
          scope.all
        else
          scope.none  # 非管理員看不到任何圖片
        end
      end

      private

      def admin?
        return false unless user

        admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
        admin_roles.any? { |role| user.has_role?(role) }
      end
    end
  end
end
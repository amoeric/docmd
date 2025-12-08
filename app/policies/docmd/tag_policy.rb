# app/policies/docmd/tag_policy.rb
module Docmd
  class TagPolicy < ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        if admin?
          scope.all
        else
          scope.all.select { |tag| visible_docs(tag).any? }
        end
      end

      private
      def visible_docs(tag)
        tag.docs.select { |doc| Docmd::DocPolicy.new(user, doc).show? }
      end
    end
  end
end

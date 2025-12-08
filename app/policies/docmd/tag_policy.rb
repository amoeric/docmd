# app/policies/docmd/tag_policy.rb
module Docmd
  class TagPolicy < ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end
  end
end

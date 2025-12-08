module Docmd
  class TagsController < ApplicationController
    apply_unauthenticated_access_from_config :tags

    after_action :verify_authorized

    # GET /tags
    # 顯示所有標籤及其文件數量
    def index
      @tags = Tag.all
      authorize Tag
    end

    # GET /tags/:id
    # 顯示特定標籤的所有文件
    def show
      @tag = Tag.find(params[:id])

      if @tag.nil?
        redirect_to tags_path, alert: "找不到標籤：#{params[:id]}"
      else
        authorize @tag
      end
    end
  end
end
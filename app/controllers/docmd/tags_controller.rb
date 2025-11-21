module Docmd
  class TagsController < ApplicationController
    # GET /tags
    # 顯示所有標籤及其文件數量
    def index
      @tags = Tag.all
    end

    # GET /tags/:id
    # 顯示特定標籤的所有文件
    def show
      @tag = Tag.find(params[:id])

      if @tag.nil?
        redirect_to tags_path, alert: "找不到標籤：#{params[:id]}"
      end
    end
  end
end
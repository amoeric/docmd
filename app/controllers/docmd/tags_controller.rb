module Docmd
  class TagsController < ApplicationController
    # GET /tags
    # 顯示所有標籤及其文件數量
    def index
      @tags = collect_all_tags
    end

    # GET /tags/:id
    # 顯示特定標籤的所有文件
    def show
      @tag = params[:id]
      @docs = DocService.find_by_tag(@tag)

      if @docs.empty?
        redirect_to tags_path, alert: "找不到標籤：#{@tag}"
      end
    end

    private

    # 收集所有文件的標籤並統計數量
    def collect_all_tags
      tags_count = Hash.new(0)

      DocService.all.each do |doc|
        doc.tags.each do |tag|
          tags_count[tag] += 1
        end
      end

      # 按照文件數量排序（多到少）
      tags_count.sort_by { |tag, count| [-count, tag] }
    end
  end
end
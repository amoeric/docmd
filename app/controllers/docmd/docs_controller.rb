module Docmd
  class DocsController < ApplicationController
    before_action :set_doc, only: [:show, :edit, :update, :destroy]

    # GET /docs
    def index
      @docs = Doc.all

      # 只顯示已發布的文件（如果需要）
      if params[:published_only] == 'true'
        @docs = @docs.select(&:published?)
      end
    end

    # GET /docs/:slug
    def show
      unless @doc
        redirect_to docs_path, alert: '找不到文件'
        return
      end

      # 根據文件的 layout 設定來決定使用哪個 Rails layout
      if @doc.metadata['layout'].present?
        # 如果 MD 檔有設定 layout，使用指定的 layout
        render :show, layout: @doc.metadata['layout']
      else
        # 如果沒有設定，使用預設的 application layout（繼承自 ::ApplicationController）
        render :show
      end
    end

    # GET /docs/new
    def new
      @doc = Doc.new
    end

    # POST /docs
    def create
      @doc = Doc.create(doc_params)

      if @doc.valid? && @doc.persisted?
        redirect_to doc_path(@doc.slug), notice: '文件建立成功'
      else
        flash.now[:alert] = @doc.errors.full_messages.join(', ') if @doc.errors.any?
        render :new
      end
    end

    # GET /docs/:slug/edit
    def edit
      unless @doc
        redirect_to docs_path, alert: '找不到文件'
      end
    end

    # PATCH/PUT /docs/:slug
    def update
      if @doc && @doc.update(doc_params)
        redirect_to doc_path(@doc.slug), notice: '文件更新成功'
      else
        flash.now[:alert] = @doc&.errors&.full_messages&.join(', ') || '更新失敗'
        render :edit
      end
    end

    # DELETE /docs/:slug
    def destroy
      if @doc && @doc.destroy
        redirect_to docs_path, notice: '文件刪除成功'
      else
        redirect_to docs_path, alert: '刪除失敗'
      end
    end

    # POST /docs/preview
    # 用於即時預覽 Markdown 內容（Turbo Frame 會用 POST 送出表單資料）
    def preview
      @doc = Doc.new
      @doc.build_from_params(doc_params)

      # 解析 Markdown 為 HTML
      parser = MarkdownParser.new
      @html_content = parser.parse(@doc.content || '')

      # 只渲染 turbo frame 部分
      render partial: 'preview', locals: { doc: @doc, html_content: @html_content }
    end

    private

    def set_doc
      @doc = Doc.find(params[:id] || params[:slug])
    end

    def doc_params
      params.require(:doc).permit(:title, :content, :slug, :layout, :date, :tags, :publish)
    end
  end
end
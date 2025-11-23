module Docmd
  class ImagesController < ApplicationController
    # GET /images
    # 圖片管理頁面
    def index
      authorize Image
      @images = policy_scope(Image, policy_scope_class: ImagePolicy::Scope)
      @pagy, @images = pagy(@images, limit: 12)
    end

    # GET /images/*path
    # 提供圖片檔案（用於顯示）
    def show
      # 組合圖片路徑
      path = params[:path]
      path += ".#{params[:format]}" if params[:format].present?

      @image = Image.find(path)

      if @image
        authorize @image
        # 發送圖片檔案
        send_file @image.full_path,
                  type: @image.content_type,
                  disposition: 'inline',
                  x_sendfile: true
      else
        raise ActionController::RoutingError, 'Image not found'
      end
    end

    # GET /images/new
    # 上傳圖片頁面
    def new
      @image = Image.new
      authorize @image
    end

    # POST /images
    # 上傳圖片
    def create
      authorize Image

      uploaded_file = params[:image][:file]
      subdirectory = params[:image][:subdirectory]

      @image = Image.upload(uploaded_file, subdirectory)

      if @image
        redirect_to images_path, notice: "圖片上傳成功：#{@image.filename}"
      else
        @image = Image.new
        flash.now[:alert] = "圖片上傳失敗"
        render :new
      end
    end

    # DELETE /images/*path
    # 刪除圖片
    def destroy
      path = params[:path]
      path += ".#{params[:format]}" if params[:format].present?

      @image = Image.find(path)

      if @image
        authorize @image
        if @image.destroy
          redirect_to images_path, notice: "圖片已刪除"
        else
          redirect_to images_path, alert: "刪除失敗"
        end
      else
        redirect_to images_path, alert: "找不到圖片"
      end
    end

    # GET /images/insert
    # 圖片插入選擇器（用於編輯器）
    def insert
      authorize Image, :index?
      @images = policy_scope(Image, policy_scope_class: ImagePolicy::Scope)
      @target = params[:target] # 目標輸入框的 ID
      render layout: false # 不使用 layout，用於彈出視窗
    end
  end
end
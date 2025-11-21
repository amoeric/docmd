require 'fileutils'
require 'mini_mime'

module Docmd
  class Image
    include ActiveModel::Model

    attr_accessor :filename, :path, :url, :size, :content_type, :created_at, :alt_text

    # 允許的圖片格式
    ALLOWED_FORMATS = %w[.jpg .jpeg .png .gif .svg .webp .ico].freeze

    def initialize(file_path = nil)
      super()
      if file_path && File.exist?(full_path_for(file_path))
        load_image(file_path)
      end
    end

    # 類別方法：取得所有圖片
    def self.all
      images = []
      image_files = Dir.glob(File.join(images_base_path, '**', '*'))
                      .select { |f| File.file?(f) && valid_image?(f) }

      image_files.each do |file_path|
        relative_path = file_path.sub("#{images_base_path}/", '')
        images << new(relative_path)
      end

      images.sort_by(&:filename)
    end

    # 類別方法：尋找特定圖片
    def self.find(path)
      image = new(path)
      image.exists? ? image : nil
    end

    # 類別方法：上傳圖片
    def self.upload(uploaded_file, subdirectory = nil)
      return nil unless uploaded_file

      # 建立檔案名稱（避免重複）
      filename = sanitize_filename(uploaded_file.original_filename)
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      unique_filename = "#{timestamp}_#{filename}"

      # 決定存放路徑
      target_dir = subdirectory ? File.join(images_base_path, subdirectory) : images_base_path
      FileUtils.mkdir_p(target_dir)

      # 相對路徑
      relative_path = subdirectory ? File.join(subdirectory, unique_filename) : unique_filename
      full_path = File.join(target_dir, unique_filename)

      # 儲存檔案
      File.open(full_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      # 回傳 Image 實例
      new(relative_path)
    rescue => e
      Rails.logger.error "圖片上傳失敗: #{e.message}"
      nil
    end

    # 類別方法：刪除圖片
    def self.delete(path)
      image = find(path)
      image&.destroy
    end

    # 取得圖片的完整路徑
    def full_path
      return nil unless @path
      full_path_for(@path)
    end

    # 檢查圖片是否存在
    def exists?
      File.exist?(full_path)
    end

    # 取得圖片 URL（用於顯示）
    def url
      return nil unless @path
      "/docmd/images/#{@path}"
    end

    # 取得圖片的 Markdown 語法
    def markdown_syntax(alt = nil)
      alt_text = alt || @alt_text || @filename
      "![#{alt_text}](#{url})"
    end

    # 取得圖片的 HTML 語法
    def html_syntax(alt = nil, css_class = nil)
      alt_text = alt || @alt_text || @filename
      class_attr = css_class ? %( class="#{css_class}") : ""
      %(<img src="#{url}" alt="#{alt_text}"#{class_attr}>)
    end

    # 刪除圖片
    def destroy
      return false unless exists?

      File.delete(full_path)
      true
    rescue => e
      errors.add(:base, "刪除失敗: #{e.message}")
      false
    end

    # 取得圖片尺寸
    def dimensions
      return nil unless exists?

      # 簡單的圖片尺寸檢測（需要額外的 gem 如 image_size 或 mini_magick 來完整實作）
      # 這裡只是預留介面
      { width: nil, height: nil }
    end

    # 取得圖片資訊
    def info
      {
        filename: @filename,
        path: @path,
        url: url,
        size: @size,
        size_formatted: format_file_size(@size),
        content_type: @content_type,
        created_at: @created_at,
        exists: exists?
      }
    end

    private

    def load_image(file_path)
      full_path = full_path_for(file_path)

      @path = file_path
      @filename = File.basename(file_path)
      @size = File.size(full_path)
      @content_type = MiniMime.lookup_by_filename(file_path)&.content_type || 'application/octet-stream'
      @created_at = File.mtime(full_path)

      # 從檔名提取 alt text（移除副檔名和底線）
      @alt_text = File.basename(@filename, '.*').gsub(/[_-]/, ' ').strip
    end

    def full_path_for(relative_path)
      File.join(self.class.images_base_path, relative_path)
    end

    def self.images_base_path
      # 使用配置的圖片路徑，預設為 docs/assets/images
      base_path = Docmd.configuration.markdown_folder_path
      File.join(base_path, 'assets', 'images')
    end

    def self.valid_image?(file_path)
      extension = File.extname(file_path).downcase
      ALLOWED_FORMATS.include?(extension)
    end

    def self.sanitize_filename(filename)
      # 移除或替換不安全的字元
      filename.gsub(/[^0-9A-Za-z.\-_]/, '_')
              .gsub(/_{2,}/, '_')
              .gsub(/^_|_$/, '')
    end

    def format_file_size(size)
      return "0 B" if size.nil? || size == 0

      units = %w[B KB MB GB]
      index = 0

      while size >= 1024 && index < units.length - 1
        size = size.to_f / 1024
        index += 1
      end

      "#{size.round(2)} #{units[index]}"
    end
  end
end
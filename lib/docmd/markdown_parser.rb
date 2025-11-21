require 'redcarpet'

module Docmd
  class MarkdownParser
    attr_reader :renderer, :markdown

    def initialize(options = {})
      # 建立 Redcarpet renderer，支援常用的 Markdown 功能
      @renderer = Redcarpet::Render::HTML.new(
        filter_html: options[:filter_html] || false,
        no_images: options[:no_images] || false,
        no_links: options[:no_links] || false,
        no_styles: options[:no_styles] || true,
        safe_links_only: options[:safe_links_only] || true,
        with_toc_data: options[:with_toc_data] || true,
        hard_wrap: options[:hard_wrap] || true,
        prettify: options[:prettify] || true
      )

      # 建立 Markdown 處理器，啟用常用的擴充功能
      @markdown = Redcarpet::Markdown.new(@renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        highlight: true,
        superscript: true,
        underline: true,
        quote: true,
        footnotes: true,
        no_intra_emphasis: true,
        lax_spacing: true
      )
    end

    # 解析單一 markdown 字串（移除 front matter）
    def parse(markdown_content)
      return "" if markdown_content.blank?

      # 移除 YAML front matter
      content_without_frontmatter = markdown_content.sub(/\A---\s*\n.*?\n---\s*\n/m, '')
      @markdown.render(content_without_frontmatter)
    end

    # 解析檔案
    def parse_file(file_path)
      return "" unless File.exist?(file_path)
      content = File.read(file_path)
      parse(content)
    end

    # 取得所有 markdown 檔案
    def self.markdown_files
      folder_path = Docmd.configuration.markdown_folder_path
      return [] unless folder_path && Dir.exist?(folder_path)

      Dir.glob(File.join(folder_path, "**", "*.md")).sort
    end

    # 解析資料夾中的所有 markdown 檔案
    def self.parse_all
      files_data = {}

      markdown_files.each do |file_path|
        relative_path = file_path.sub("#{Docmd.configuration.markdown_folder_path}/", "")
        parser = new

        files_data[relative_path] = {
          path: file_path,
          content: File.read(file_path),
          html: parser.parse_file(file_path),
          metadata: extract_metadata(file_path)
        }
      end

      files_data
    end

    # 從檔案提取元資料（例如 front matter）
    def self.extract_metadata(file_path)
      return {} unless File.exist?(file_path)

      content = File.read(file_path)
      metadata = {}

      # 檢查是否有 YAML front matter
      if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
        begin
          require 'yaml'
          metadata = YAML.safe_load($1, permitted_classes: [Date, Time, DateTime])
        rescue => e
          Rails.logger.error "Error parsing YAML front matter in #{file_path}: #{e.message}" if defined?(Rails)
        end
      end

      # 加入檔案資訊
      metadata.merge!(
        'filename' => File.basename(file_path),
        'path' => file_path,
        'updated_at' => File.mtime(file_path),
        'slug' => File.basename(file_path, '.md')
      )

      # 確保有標題
      metadata['title'] ||= File.basename(file_path, '.md').humanize

      metadata
    end

    # 分離 front matter 和內容
    def self.split_content(file_content)
      if file_content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)/m
        front_matter = $1
        content = $2
        [front_matter, content]
      else
        [nil, file_content]
      end
    end
  end
end
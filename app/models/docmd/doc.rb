require 'yaml'
require 'fileutils'
require 'time'
require 'date'

module Docmd
  class Doc
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :file_path, :metadata, :content, :slug
    attr_accessor :title, :layout, :date, :tags, :publish, :roles

    def initialize(file_path = nil)
      super()  # 重要：呼叫 ActiveModel::Model 的初始化
      @file_path = file_path
      @metadata = {}
      load_file if file_path && File.exist?(full_path)
    end

    # 類別方法：取得所有文件
    def self.all
      docs = []
      markdown_files = MarkdownParser.markdown_files

      markdown_files.each do |path|
        doc = new(relative_path(path))
        docs << doc if doc.valid?
      end

      # 根據 front matter 的設定排序
      docs.sort_by { |doc| [doc.metadata['position'] || 999, doc.metadata['date'] || Time.now] }
    end

    # 類別方法：尋找單一文件
    def self.find(slug)
      # 先嘗試直接用 slug 找檔案
      file_path = "#{slug}.md"
      doc = new(file_path)
      return doc if doc.exists?

      # 如果找不到，搜尋所有檔案
      all.find { |d| d.slug == slug }
    end

    # 類別方法：建立新文件
    def self.create(params)
      doc = new
      doc.build_from_params(params)
      doc.save
      doc
    end

    # 類別方法：按標籤查找文件
    def self.find_by_tag(tag)
      all.select do |doc|
        doc.tags.include?(tag)
      end
    end

    # 實例方法：讀取檔案
    def load_file
      return unless exists?

      file_content = File.read(full_path)
      front_matter, @content = MarkdownParser.split_content(file_content)

      @metadata = if front_matter
        YAML.safe_load(front_matter, permitted_classes: [Date, Time, DateTime]) || {}
      else
        {}
      end

      @metadata['slug'] = File.basename(@file_path, '.md')
      @metadata['title'] ||= @metadata['slug'].humanize
      @slug = @metadata['slug']
    end

    # 從參數建立文件
    def build_from_params(params)
      @metadata = {
        'title' => params[:title],
        'date' => parse_date(params[:date]),
        'tags' => parse_tags(params[:tags]),
        'publish' => params[:publish] == 'true' || params[:publish] == true
      }

      # 只有在有值時才設定 layout，避免寫入空值
      @metadata['layout'] = params[:layout] if params[:layout].present?

      # 處理 roles 設定（用於權限控制）
      @metadata['roles'] = parse_roles(params[:roles]) if params[:roles].present?

      @content = params[:content] || ''
      @slug = params[:slug] || params[:title]&.parameterize

      # 設定檔案路徑
      @file_path = "#{@slug}.md" if @slug
    end

    # 更新文件
    def update(params)
      build_from_params(params)
      save
    end

    # 儲存文件
    def save
      return false unless valid?

      # 建立 front matter
      front_matter = @metadata.to_yaml
      full_content = "---\n#{front_matter}---\n\n#{@content}"

      # 確保目錄存在
      FileUtils.mkdir_p(File.dirname(full_path))

      # 寫入檔案
      File.write(full_path, full_content)
      true
    rescue => e
      errors.add(:base, "儲存失敗: #{e.message}")
      false
    end

    # 刪除文件
    def destroy
      return false unless exists?

      File.delete(full_path)
      true
    rescue => e
      errors.add(:base, "刪除失敗: #{e.message}")
      false
    end

    # 檢查檔案是否存在
    def exists?
      @file_path && File.exist?(full_path)
    end

    # 驗證 (使用 ActiveModel 的驗證)
    def valid?
      errors.clear
      errors.add(:title, "不能為空") if title.to_s.strip.empty?
      errors.add(:slug, "不能為空") if @slug.to_s.strip.empty?
      errors.empty?
    end

    # 取得完整路徑
    def full_path
      return nil unless @file_path
      File.join(Docmd.configuration.markdown_folder_path, @file_path)
    end

    # 取得 HTML 內容
    def html_content
      @html_content ||= begin
        parser = MarkdownParser.new
        parser.parse(@content || '')
      end
    end

    # 是否已發布
    def published?
      @metadata['publish'] == true
    end

    # 取得標題
    def title
      @metadata&.dig('title') || @slug&.humanize || 'Untitled'
    end

    # 取得日期
    def date
      date_value = @metadata&.dig('date')

      if date_value.nil?
        # 如果沒有設定日期，使用檔案修改時間
        # 先檢查 full_path 是否為 nil（例如新建文件時）
        path = full_path
        return (path && File.exist?(path)) ? File.mtime(path) : Time.current
      end

      # 處理各種日期格式
      case date_value
      when Time, DateTime, Date
        date_value.to_time
      when String
        begin
          Time.parse(date_value)
        rescue ArgumentError
          Time.current
        end
      else
        Time.current
      end
    end

    # 取得標籤
    def tags
      @metadata&.dig('tags') || []
    end

    # 取得角色限制
    def roles
      @metadata&.dig('roles') || []
    end

    # 檢查使用者是否有權限查看文件
    # user: 主應用程式的使用者物件（需要支援 has_role? 方法）
    # 返回 true 表示有權限，false 表示無權限
    def accessible_by?(user = nil)
      # 如果沒有設定 roles，表示所有人都可以看
      return true if roles.empty?

      # 如果沒有使用者（未登入），無法查看有角色限制的文件
      return false if user.nil?

      # 檢查使用者是否有任何符合的角色
      # 假設主應用程式的 User 模型使用 rolify gem
      if user.respond_to?(:has_role?)
        # 檢查使用者是否擁有最高權限角色（可以查看所有文件）
        admin_roles = Docmd.configuration.admin_roles || [:admin]
        return true if admin_roles.any? { |role| user.has_role?(role) }

        # 檢查使用者是否有文件要求的任何角色
        roles.any? { |role| user.has_role?(role.to_sym) }
      else
        # 如果使用者物件不支援 has_role?，預設無權限
        false
      end
    end

    # 用於表單
    def to_param
      @slug
    end

    def persisted?
      exists?
    end

    private

    # 解析標籤字串
    def parse_tags(tags_input)
      return [] if tags_input.blank?

      if tags_input.is_a?(String)
        tags_input.split(',').map(&:strip)
      else
        Array(tags_input)
      end
    end

    # 解析角色字串
    def parse_roles(roles_input)
      return [] if roles_input.blank?

      if roles_input.is_a?(String)
        roles_input.split(',').map(&:strip).map(&:downcase)
      else
        Array(roles_input).map(&:to_s).map(&:downcase)
      end
    end

    # 解析日期
    def parse_date(date_input)
      return Time.current if date_input.blank?

      case date_input
      when Time, DateTime, Date
        date_input
      when String
        begin
          Time.parse(date_input)
        rescue ArgumentError
          Time.current
        end
      else
        Time.current
      end
    end

    # 取得相對路徑
    def self.relative_path(full_path)
      base_path = Docmd.configuration.markdown_folder_path.to_s
      full_path.sub("#{base_path}/", '')
    end
  end
end
module Docmd
  class Configuration
    attr_accessor :markdown_folder_path, :layout, :admin_roles, :show_toc

    def initialize
      @markdown_folder_path = Rails.root.join('docs') if defined?(Rails)
      @layout = 'application'  # 預設使用主應用程式的 application layout
      # 預設的最高權限角色（可查看所有文件）
      @admin_roles = [:admin, :super_admin]
      # 是否顯示文件大綱目錄 (TOC)
      @show_toc = true  # 預設顯示
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
module Docmd
  class Configuration
    attr_accessor :markdown_folder_path, :layout, :admin_roles, :show_toc, :toc_position, :allow_unauthenticated_access

    def initialize
      @markdown_folder_path = Rails.root.join('docs') if defined?(Rails)
      @layout = 'application'  # 預設使用主應用程式的 application layout
      # 預設的最高權限角色（可查看所有文件）
      @admin_roles = [:admin, :super_admin]
      # 是否顯示文件大綱目錄 (TOC)
      @show_toc = true  # 預設顯示
      # TOC 位置設定 (:left 或 :right)
      @toc_position = :right  # 預設在右邊
      # 允許未認證訪問的頁面設定
      # 格式: { controller: [actions] } 或 { controller: :all }
      # 例如: { docs: [:index, :show], tags: :all }
      @allow_unauthenticated_access = {}
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
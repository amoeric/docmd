module Docmd
  class Configuration
    attr_accessor :markdown_folder_path, :layout

    def initialize
      @markdown_folder_path = Rails.root.join('docs') if defined?(Rails)
      @layout = 'application'  # 預設使用主應用程式的 application layout
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
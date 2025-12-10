require 'pagy'

module Docmd
  class Engine < ::Rails::Engine
    isolate_namespace Docmd

    # 將 engine 的資產路徑加入 Rails 的資產管線（用於 CSS 和圖片）
    initializer "docmd.assets" do |app|
      app.config.assets.paths << Engine.root.join("app/assets/stylesheets")
      app.config.assets.paths << Engine.root.join("app/assets/images")
      app.config.assets.paths << Engine.root.join("app/assets/builds")
    end

    initializer "docmd.assets.precompile" do |app|
      app.config.assets.precompile += %w( docmd/tailwind.css )
    end

    # 配置 JavaScript（支援 importmap 和 esbuild）
    initializer "docmd.javascript", before: "importmap" do |app|
      # 將 engine 的 JavaScript 路徑加入 Rails 的資產路徑
      javascript_path = Engine.root.join("app/javascript")
      app.config.assets.paths << javascript_path

      # 支援 importmap
      if app.config.respond_to?(:importmap)
        importmap_path = Engine.root.join("config/importmap.rb")
        app.config.importmap.paths << importmap_path if importmap_path.exist?
        Rails.logger.debug "✅ Docmd Engine: Importmap configured"
      end

      # 支援 esbuild/jsbundling-rails
      # esbuild 會自動從 app/javascript 路徑中解析模組
      # 主應用程式只需要 import "docmd" 即可
      Rails.logger.debug "✅ Docmd Engine: JavaScript paths configured for esbuild/importmap"
      puts "✅ Docmd Engine: JavaScript configured (supports importmap & esbuild)" if Rails.env.development?
    end

    # Engine 載入時執行
    config.to_prepare do
      Rails.logger.debug "✅ Docmd Engine: Engine prepared"
    end
  end
end

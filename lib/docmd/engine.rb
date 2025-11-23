require 'pagy'

module Docmd
  class Engine < ::Rails::Engine
    isolate_namespace Docmd

    # 將 engine 的資產路徑加入 Rails 的資產管線（用於 CSS 和圖片）
    initializer "docmd.assets" do |app|
      app.config.assets.paths << Engine.root.join("app/assets/stylesheets")
      app.config.assets.paths << Engine.root.join("app/assets/images")
    end

    # 設定 CSS 資產預編譯
    initializer "docmd.assets.precompile" do |app|
      app.config.assets.precompile += %w( docmd/application.css )
    end

    # 配置 importmap（用於 JavaScript）
    initializer "docmd.importmap", before: "importmap" do |app|
      # 將 engine 的 JavaScript 路徑加入 Rails 的資產路徑
      app.config.assets.paths << Engine.root.join("app/javascript")

      # 如果主應用程式有使用 importmap，自動載入 engine 的 importmap 配置
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
      end

      # 開發環境下可以看到載入訊息
      Rails.logger.debug "✅ Docmd Engine: Importmap configured"
      puts "✅ Docmd Engine loaded and importmap configured" if Rails.env.development?
    end

    # Engine 載入時執行
    config.to_prepare do
      Rails.logger.debug "✅ Docmd Engine: Engine prepared"
    end
  end
end

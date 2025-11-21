module Docmd
  class Engine < ::Rails::Engine
    isolate_namespace Docmd

    # 將 engine 的資產路徑加入 Rails 的資產管線
    initializer "docmd.assets" do |app|
      app.config.assets.paths << Engine.root.join("app/assets/stylesheets")
      app.config.assets.paths << Engine.root.join("app/assets/javascripts")
      app.config.assets.paths << Engine.root.join("app/assets/images")
    end

    # 設定資產預編譯
    initializer "docmd.assets.precompile" do |app|
      # 因為有 isolate_namespace，所以需要用 namespace 前綴
      app.config.assets.precompile += %w( docmd/application.css )

      # 開發環境下可以看到載入訊息
      Rails.logger.debug "✅ Docmd Engine: Assets precompile configured"
      puts "✅ Docmd Engine loaded and assets configured" if Rails.env.development?
    end

    # Engine 載入時執行
    config.to_prepare do
      Rails.logger.debug "✅ Docmd Engine: Engine prepared"
    end
  end
end

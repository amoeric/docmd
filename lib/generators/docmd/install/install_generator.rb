require 'rails/generators/base'
require 'json'

module Docmd
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Creates a Docmd initializer file in your Rails application"

      def copy_initializer
        template 'docmd.rb', 'config/initializers/docmd.rb'
      end

      def create_docs_folder
        empty_directory 'docs'
        empty_directory 'docs/assets'
        empty_directory 'docs/assets/images'
        create_file 'docs/.keep'
        create_file 'docs/assets/images/.keep'
      end

      def setup_javascript
        application_js_path = 'app/javascript/application.js'
        
        # 檢測主應用程式使用的 JavaScript 打包工具
        uses_esbuild = detect_esbuild
        uses_importmap = detect_importmap
        
        if File.exist?(application_js_path)
          # 檢查是否已經有 import "docmd"
          content = File.read(application_js_path)
          
          unless content.include?('import "docmd"') || content.include?("import 'docmd'")
            # 根據使用的工具選擇合適的 import 語句
            import_statement = if uses_esbuild
              # esbuild 使用標準 ES6 import
              "\n// Docmd Engine JavaScript\nimport \"docmd\""
            else
              # importmap 也使用相同的語法
              "\n// Docmd Engine JavaScript\nimport \"docmd\""
            end
            
            append_to_file application_js_path, import_statement
            say "✅ 已自動在 #{application_js_path} 中添加 import \"docmd\"", :green
            
            if uses_esbuild
              say "   (檢測到 esbuild，已自動配置)", :green
            elsif uses_importmap
              say "   (檢測到 importmap，已自動配置)", :green
            end
          else
            say "✓ #{application_js_path} 中已經有 import \"docmd\"", :blue
          end
        else
          say "⚠️  未找到 #{application_js_path}，請手動添加：import \"docmd\"", :yellow
        end
        
        # 顯示配置資訊
        if uses_esbuild && uses_importmap
          say "ℹ️  檢測到同時使用 esbuild 和 importmap，兩者都已配置", :blue
        elsif uses_esbuild
          say "ℹ️  檢測到使用 esbuild，JavaScript 已自動配置", :blue
        elsif uses_importmap
          say "ℹ️  檢測到使用 importmap，JavaScript 已自動配置", :blue
        end
      end

      private

      def detect_esbuild
        # 檢查是否有 package.json 且包含 esbuild
        package_json_path = 'package.json'
        if File.exist?(package_json_path)
          begin
            package_json = JSON.parse(File.read(package_json_path))
            # 檢查是否有 esbuild 相關的依賴或腳本
            deps = (package_json['dependencies'] || {}).merge(package_json['devDependencies'] || {})
            scripts = package_json['scripts'] || {}
            
            return true if deps.key?('esbuild') || 
                          scripts.values.any? { |s| s.include?('esbuild') } ||
                          File.exist?('esbuild.config.js') ||
                          File.exist?('esbuild.config.mjs')
          rescue JSON::ParserError
            # 忽略 JSON 解析錯誤
          end
        end
        
        # 檢查 Gemfile 是否有 jsbundling-rails
        gemfile_path = 'Gemfile'
        if File.exist?(gemfile_path)
          gemfile_content = File.read(gemfile_path)
          return true if gemfile_content.include?('jsbundling-rails')
        end
        
        false
      end

      def detect_importmap
        # 檢查是否有 importmap.rb
        return true if File.exist?('config/importmap.rb')
        
        # 檢查 Gemfile 是否有 importmap-rails
        gemfile_path = 'Gemfile'
        if File.exist?(gemfile_path)
          gemfile_content = File.read(gemfile_path)
          return true if gemfile_content.include?('importmap-rails')
        end
        
        false
      end

      def display_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
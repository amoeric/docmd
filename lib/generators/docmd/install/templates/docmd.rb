# Docmd 配置檔
# 這個檔案用來設定 Docmd engine 的相關配置

Docmd.configure do |config|
  # 設定 Markdown 檔案所在的資料夾路徑
  # 預設為 Rails.root.join('docs')
  # 你可以設定為任何你想要的路徑
  config.markdown_folder_path = Rails.root.join('docs')

  # 範例：使用不同的資料夾
  # config.markdown_folder_path = Rails.root.join('app', 'documents')
  # config.markdown_folder_path = Rails.root.join('public', 'markdown')
  # config.markdown_folder_path = '/absolute/path/to/markdown/files'

  # 設定擁有最高權限的角色（可以查看所有文件，無視文件的角色限制）
  # 預設為 [:admin, :super_admin]
  # 需要主應用程式安裝 rolify gem
  # config.admin_roles = [:admin, :super_admin]

  # 你可以根據專案需求自訂，例如：
  # config.admin_roles = [:admin]  # 只有 admin 角色有最高權限
  # config.admin_roles = [:super_admin, :moderator]  # 多個角色有最高權限
  # config.admin_roles = []  # 沒有任何角色有最高權限，所有人都要遵守文件的角色限制

  # 是否顯示文件大綱目錄 (Table of Contents)
  # 預設為 true，會在文件右側顯示基於標題（h1, h2, h3）的樹狀目錄
  # 設為 false 可以隱藏目錄，讓文章內容佔滿整個寬度
  config.show_toc = true

  # 範例：隱藏文件大綱目錄
  # config.show_toc = false
end
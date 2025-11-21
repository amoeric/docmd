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
end
module Docmd
  module ApplicationHelper
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TextHelper

    # 輔助方法：取得文件的純文字摘要
    def doc_summary(doc, length = 200)
      return "" unless doc.content.present?

      # 移除 Markdown 語法和 HTML 標籤
      plain_text = strip_tags(doc.content)
        .gsub(/^#+\s+/, '')  # 移除標題符號
        .gsub(/\*\*(.*?)\*\*/, '\1')  # 移除粗體
        .gsub(/\*(.*?)\*/, '\1')  # 移除斜體
        .gsub(/\[([^\]]+)\]\([^\)]+\)/, '\1')  # 移除連結
        .gsub(/`([^`]+)`/, '\1')  # 移除行內程式碼
        .gsub(/```[^`]*```/, '')  # 移除程式碼區塊
        .gsub(/^[-*]\s+/, '')  # 移除列表符號
        .strip

      truncate(plain_text, length: length)
    end
  end
end

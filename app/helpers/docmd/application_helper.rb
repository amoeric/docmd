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

    # 從 HTML 內容中提取標題結構（h1, h2, h3）
    def extract_headings_structure(html_content)
      return [] if html_content.blank?

      doc = Nokogiri::HTML.fragment(html_content)
      headings = []
      stack = []

      doc.css('h1, h2, h3').each do |heading|
        level = heading.name[1].to_i  # 取得 1, 2, 或 3
        text = heading.text.strip
        id = heading['id'] || text.parameterize

        # 建立標題節點
        node = {
          level: level,
          text: text,
          id: id,
          children: []
        }

        # 根據層級建立階層結構
        if level == 1
          headings << node
          stack = [node]
        elsif level == 2
          if stack.any? && stack.first[:level] == 1
            stack.first[:children] << node
            stack[1] = node
          else
            headings << node
            stack = [node]
          end
        elsif level == 3
          if stack.length >= 2 && stack[1][:level] == 2
            stack[1][:children] << node
          elsif stack.any? && stack.first[:level] == 2
            stack.first[:children] << node
          elsif stack.any? && stack.first[:level] == 1
            stack.first[:children] << node
          else
            headings << node
          end
        end
      end

      headings
    end

    # 產生樹狀目錄 HTML
    def render_tree_view_toc(doc)
      headings = extract_headings_structure(doc.html_content)
      return "" if headings.empty?

      content_tag(:div,
        {
          data: {
            controller: "docmd--tree-view",
            "docmd--tree-view-animate-value": true
          },
          class: "w-64 h-fit p-4 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 overflow-auto shrink-0"
        }
      ) do
        render_heading_nodes(headings)
      end
    end

    private

    def render_heading_nodes(nodes, level = 0)
      return "" if nodes.empty?

      safe_join(nodes.map { |node| render_heading_node(node, level) })
    end

    def render_heading_node(node, level)
      has_children = node[:children].any?
      unique_id = "tree-content-#{node[:id]}"
      indent_class = level > 0 ? "ml-4 pl-2 border-l border-neutral-200 dark:border-neutral-700" : ""

      content_tag(:div, class: "overflow-hidden #{indent_class}") do
        content = ""

        if has_children
          # 有子節點的標題
          content << content_tag(:button,
            {
              type: "button",
              data: {
                action: "click->docmd--tree-view#toggle",
                heading_id: node[:id]
              },
              aria: {
                controls: unique_id,
                expanded: "true"
              },
              "data-state": "open",
              class: "flex w-full items-center gap-2 rounded-md px-3 py-1.5 text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors duration-150 outline-none"
            }
          ) do
            indicator = content_tag(:span, "", {
              class: "w-1 h-4 bg-red-500 rounded-sm hidden",
              data: { "docmd--tree-view-target": "indicator" }
            })
            text = content_tag(:span, node[:text], class: "font-medium")
            indicator + text
          end

          # 子節點容器
          content << content_tag(:div,
            {
              id: unique_id,
              "data-state": "open",
              role: "region",
              data: { "docmd--tree-view-target": "content" },
              class: "ml-4 pl-2 border-l border-neutral-200 dark:border-neutral-700 space-y-1 overflow-hidden transition-[height]"
            }
          ) do
            render_heading_nodes(node[:children], level + 1)
          end
        else
          # 沒有子節點的標題（顯示為檔案）
          text_class = node[:level] == 2 ? "font-medium" : ""
          content << content_tag(:a,
            {
              href: "##{node[:id]}",
              data: { action: "click->docmd--tree-view#scrollToHeading" },
              class: "flex w-full items-center gap-2 rounded-md px-3 py-1.5 text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors duration-150 outline-none"
            }
          ) do
            indicator = content_tag(:span, "", {
              class: "w-1 h-4 bg-red-500 rounded-sm hidden",
              data: { "docmd--tree-view-target": "indicator" }
            })
            text = content_tag(:span, node[:text], class: text_class)
            indicator + text
          end
        end

        content.html_safe
      end
    end
  end
end

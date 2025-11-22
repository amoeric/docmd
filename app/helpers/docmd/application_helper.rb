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
          class: "sticky top-4 w-64 max-h-[calc(100vh-2rem)] p-4 rounded-lg border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 overflow-auto shrink-0"
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
          # 有子節點的標題（顯示為資料夾）
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
              class: "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors duration-150 outline-hidden focus:border-b-2 focus:border-red-500"
            }
          ) do
            folder_icon + content_tag(:span, node[:text], class: "font-medium")
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
          content << content_tag(:a,
            {
              href: "##{node[:id]}",
              data: { action: "click->docmd--tree-view#scrollToHeading" },
              class: "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-sm text-neutral-600 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors duration-150 outline-hidden focus:border-b-2 focus:border-red-500"
            }
          ) do
            file_icon + content_tag(:span, node[:text])
          end
        end

        content.html_safe
      end
    end

    def folder_icon
      content_tag(:svg,
        {
          data: { "docmd--tree-view-target": "icon" },
          class: "folder-open",
          xmlns: "http://www.w3.org/2000/svg",
          width: "18",
          height: "18",
          viewBox: "0 0 18 18"
        }
      ) do
        <<~SVG.html_safe
          <g fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" stroke="currentColor">
            <path d="M5,14.75h-.75c-1.105,0-2-.895-2-2V4.75c0-1.105,.895-2,2-2h1.825c.587,0,1.144,.258,1.524,.705l1.524,1.795h4.626c1.105,0,2,.895,2,2v1"></path>
            <path d="M16.148,13.27l.843-3.13c.257-.953-.461-1.89-1.448-1.89H6.15c-.678,0-1.272,.455-1.448,1.11l-.942,3.5c-.257,.953,.461,1.89,1.448,1.89H14.217c.904,0,1.696-.607,1.931-1.48Z"></path>
          </g>
        SVG
      end
    end

    def file_icon
      content_tag(:svg,
        xmlns: "http://www.w3.org/2000/svg",
        width: "18",
        height: "18",
        viewBox: "0 0 18 18"
      ) do
        <<~SVG.html_safe
          <g fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" stroke="currentColor">
            <path d="M15.16,6.25h-3.41c-.552,0-1-.448-1-1V1.852"></path>
            <path d="M2.75,14.25V3.75c0-1.105,.895-2,2-2h5.586c.265,0,.52,.105,.707,.293l3.914,3.914c.188,.188,.293,.442,.293,.707v7.586c0,1.105-.895,2-2,2H4.75c-1.105,0-2-.895-2-2Z"></path>
          </g>
        SVG
      end
    end
  end
end

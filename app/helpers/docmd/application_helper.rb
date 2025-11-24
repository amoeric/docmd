module Docmd
  module ApplicationHelper
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TextHelper

    # 輔助方法：顯示文件權限 badge
    def doc_permission_badge(doc)
      if !doc.published?
        # 草稿：只有管理員可以看
        content_tag(:span, class: "ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800") do
          icon = content_tag(:svg, class: "w-3 h-3 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z")
          end
          icon + "僅管理員"
        end
      elsif doc.roles.empty?
        # 已發布且無角色限制：所有人可以看
        content_tag(:span, class: "ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800") do
          icon = content_tag(:svg, class: "w-3 h-3 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z")
          end
          icon + "公開閱讀"
        end
      else
        # 已發布且有角色限制：只有特定角色可以看
        content_tag(:span, class: "ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800") do
          icon = content_tag(:svg, class: "w-3 h-3 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z")
          end
          icon + doc.roles.join(', ')
        end
      end
    end

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

    # 從 HTML 內容中提取標題結構（h1, h2, h3, h4）
    def extract_headings_structure(html_content)
      return [] if html_content.blank?

      doc = Nokogiri::HTML.fragment(html_content)
      headings = []
      stack = []

      doc.css('h1, h2, h3, h4').each do |heading|
        level = heading.name[1].to_i  # 取得 1, 2, 3, 或 4
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
            stack[2] = node
          elsif stack.any? && stack.first[:level] == 2
            stack.first[:children] << node
            stack[1] = node
          elsif stack.any? && stack.first[:level] == 1
            stack.first[:children] << node
            stack[1] = node
          else
            headings << node
            stack = [node]
          end
        elsif level == 4
          if stack.length >= 3 && stack[2][:level] == 3
            stack[2][:children] << node
          elsif stack.length >= 2 && stack[1][:level] == 3
            stack[1][:children] << node
          elsif stack.any? && stack.first[:level] == 3
            stack.first[:children] << node
          elsif stack.length >= 2 && stack[1][:level] == 2
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

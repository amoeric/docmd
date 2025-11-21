module Docmd
  class Tag
    include ActiveModel::Model

    attr_accessor :name, :count, :docs

    def initialize(name: nil, count: 0)
      @name = name
      @count = count
      @docs = []
    end

    # 類別方法：取得所有標籤及其文件數量
    def self.all
      tags_hash = Hash.new { |h, k| h[k] = new(name: k, count: 0) }

      Doc.all.each do |doc|
        doc.tags.each do |tag_name|
          tag = tags_hash[tag_name]
          tag.count += 1
          tag.docs << doc
        end
      end

      # 回傳按照文件數量排序的標籤陣列
      tags_hash.values.sort_by { |tag| [-tag.count, tag.name] }
    end

    # 類別方法：尋找特定標籤
    def self.find(name)
      tag = new(name: name)

      # 找出所有包含此標籤的文件
      tag.docs = Doc.find_by_tag(name)
      tag.count = tag.docs.size

      tag.docs.any? ? tag : nil
    end

    # 類別方法：取得標籤統計（回傳 Hash）
    def self.statistics
      tags_count = Hash.new(0)

      Doc.all.each do |doc|
        doc.tags.each do |tag|
          tags_count[tag] += 1
        end
      end

      # 按照文件數量排序
      tags_count.sort_by { |tag, count| [-count, tag] }.to_h
    end

    # 類別方法：取得熱門標籤
    def self.popular(limit = 10)
      all.take(limit)
    end

    # 類別方法：取得相關標籤（基於共同出現）
    def self.related_to(tag_name, limit = 10)
      target_tag = find(tag_name)
      return [] unless target_tag

      related_tags = Hash.new(0)

      # 統計在相同文件中出現的其他標籤
      target_tag.docs.each do |doc|
        doc.tags.each do |tag|
          next if tag == tag_name
          related_tags[tag] += 1
        end
      end

      # 轉換為 Tag 物件並排序
      related_tags.map do |name, count|
        new(name: name, count: count)
      end.sort_by { |tag| -tag.count }.take(limit)
    end

    # 實例方法：取得標籤的 URL
    def to_param
      @name
    end

    # 實例方法：判斷是否為熱門標籤
    def popular?
      @count >= 5  # 可以根據需求調整閾值
    end

    # 實例方法：取得標籤大小級別（用於標籤雲）
    def size_level
      case @count
      when 1 then :xs
      when 2..3 then :sm
      when 4..6 then :md
      when 7..10 then :lg
      else :xl
      end
    end

    # 實例方法：取得標籤顏色級別（用於標籤雲）
    def color_level
      case @count
      when 1 then 'blue-100'
      when 2..3 then 'blue-200'
      when 4..6 then 'blue-300'
      when 7..10 then 'blue-400'
      else 'blue-500'
      end
    end

    # 實例方法：取得已發布的文件
    def published_docs
      @docs.select(&:published?)
    end

    # 實例方法：取得草稿文件
    def draft_docs
      @docs.reject(&:published?)
    end
  end
end
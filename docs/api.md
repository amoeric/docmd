# API 文件

## 文件服務 API

### 取得所有文件
```ruby
docs = Docmd::Doc.all
# 回傳文件物件陣列
```

### 尋找特定文件
```ruby
doc = Docmd::Doc.find('my-document')
# 使用 slug 尋找文件
```

### 建立新文件
```ruby
doc = Docmd::Doc.create(
  title: '新文件',
  content: '# 內容',
  tags: 'rails, ruby',
  publish: true,
  roles: 'admin, editor'  # 可選
)
```

### 更新文件
```ruby
doc = Docmd::Doc.find('my-document')
doc.update(
  title: '更新的標題',
  content: '更新的內容',
  tags: 'rails, tutorial'
)
```

### 刪除文件
```ruby
doc = Docmd::Doc.find('my-document')
doc.destroy
```

### 按標籤查找文件
```ruby
# 尋找特定標籤的文件
docs = Docmd::Doc.find_by_tag('rails')
```

## 文件物件屬性

```ruby
doc = Docmd::Doc.find('my-document')

# 基本屬性
doc.title         # => "文件標題"
doc.slug          # => "my-document"
doc.content       # => "原始 Markdown 內容"
doc.html_content  # => "轉換後的 HTML"

# 元資料
doc.metadata      # => Hash 包含所有 front matter
doc.date          # => Time 物件
doc.tags          # => ["rails", "ruby"]
doc.roles         # => ["admin", "editor"]
doc.published?    # => true/false

# 路徑相關
doc.file_path     # => "my-document.md"
doc.full_path     # => "/full/path/to/docs/my-document.md"

# 狀態檢查
doc.exists?       # => true/false
doc.valid?        # => true/false
doc.persisted?    # => true/false

# 權限檢查
doc.accessible_by?(user)  # => true/false
```

## MarkdownParser API

### 基本使用
```ruby
parser = Docmd::MarkdownParser.new

# 解析 Markdown 字串
html = parser.parse("# 標題\n\n內容")

# 解析檔案
html = parser.parse_file('/path/to/file.md')
```

### 批量操作
```ruby
# 取得所有 Markdown 檔案
files = Docmd::MarkdownParser.markdown_files
# => ["/path/to/file1.md", "/path/to/file2.md"]

# 解析所有檔案
all_docs = Docmd::MarkdownParser.parse_all
# => Hash with file paths as keys
```

### 分離 Front Matter
```ruby
file_content = File.read('document.md')
front_matter, content = Docmd::MarkdownParser.split_content(file_content)
# front_matter => YAML 字串
# content => Markdown 內容
```

## Image API

### 取得所有圖片
```ruby
images = Docmd::Image.all
# 回傳 Image 物件陣列
```

### 尋找特定圖片
```ruby
image = Docmd::Image.find('screenshot.png')
# 或包含路徑
image = Docmd::Image.find('aws/step1.png')
```

### 圖片屬性
```ruby
image.filename        # => "screenshot.png"
image.path           # => "aws/screenshot.png"
image.full_path      # => "/full/path/to/docs/assets/images/aws/screenshot.png"
image.url            # => "/docmd/images/aws/screenshot.png"
image.markdown_syntax # => "![screenshot](/docmd/images/aws/screenshot.png)"
image.alt_text       # => "screenshot"
image.info[:size]    # => 12345 (bytes)
image.info[:size_formatted] # => "12.3 KB"
```

### 上傳圖片
```ruby
# 在 controller 中
def create
  uploaded_file = params[:file]
  subfolder = params[:subfolder]  # 可選

  image = Docmd::Image.upload(uploaded_file, subfolder)

  if image
    # 上傳成功
    redirect_to images_path, notice: "圖片上傳成功"
  else
    # 上傳失敗
    redirect_back fallback_location: images_path, alert: "上傳失敗"
  end
end
```

### 刪除圖片
```ruby
image = Docmd::Image.find('screenshot.png')
if image.destroy
  # 刪除成功
else
  # 刪除失敗
end
```
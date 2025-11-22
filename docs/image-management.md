# 圖片管理功能

Docmd 提供完整的圖片管理功能，圖片儲存在 `docs/assets/images/` 目錄下。

## 圖片存放位置

預設圖片路徑：`docs/assets/images/`

目錄結構範例：
```
docs/
  assets/
    images/
      screenshot.png
      aws/
        awsstep1.png
        awsstep2.png
```

## 在 Markdown 中插入圖片

```markdown
# 基本語法
![圖片描述](/docmd/images/screenshot.png)

# 子目錄中的圖片
![AWS Step 1](/docmd/images/aws/awsstep1.png)

# HTML 語法（需要自訂樣式時）
<img src="/docmd/images/screenshot.png" alt="截圖" class="w-full">
```

## 圖片管理介面

訪問 `/docmd/images` 可以：
- 查看所有圖片
- 上傳新圖片
- 複製圖片的 Markdown 語法或 URL
- 刪除圖片

## 使用 Image Model

```ruby
# 取得所有圖片
images = Docmd::Image.all

# 尋找特定圖片
image = Docmd::Image.find('screenshot.png')

# 取得圖片資訊
image.url           # => "/docmd/images/screenshot.png"
image.markdown_syntax  # => "![screenshot](/docmd/images/screenshot.png)"
image.full_path     # => "/path/to/docs/assets/images/screenshot.png"

# 上傳圖片（在 controller 中）
image = Docmd::Image.upload(params[:file], 'aws')  # 上傳到 aws 子目錄
```

## 支援的圖片格式

- JPG / JPEG
- PNG
- GIF
- SVG
- WebP
- ICO
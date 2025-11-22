# 角色權限功能

Docmd 支援基於角色的權限控制系統，可與主應用程式的 [rolify](https://github.com/RolifyCommunity/rolify) gem 整合。

## 功能特點

- 可設定哪些角色可以查看特定文件
- 與主應用程式的使用者系統整合
- 管理員（admin）角色可查看所有文件
- 向下相容：如果主應用程式沒有 rolify，功能會自動停用

## 前置需求

### 1. 主應用程式安裝 rolify

```ruby
# Gemfile
gem 'rolify'

# 安裝
bundle install
rails generate rolify Role User
rails db:migrate
```

### 2. User 模型設定

```ruby
class User < ApplicationRecord
  rolify
  # 其他設定...
end
```

### 3. 設定使用者角色

```ruby
# 新增角色
user.add_role :admin
user.add_role :editor
user.add_role :member

# 檢查角色
user.has_role? :admin  # => true/false
```

## 使用方式

### 在 Markdown 文件設定權限

在 front matter 中設定 `roles`：

```markdown
---
title: 內部文件
date: 2025-01-01
roles:
  - admin
  - editor
publish: true
---

# 內部文件內容

只有擁有 admin 或 editor 角色的使用者可以查看此文件。
```

### 在表單中設定權限

在新增或編輯文件時，可以在「權限角色」欄位設定：

```
權限角色：admin, editor, member
```

- 用逗號分隔多個角色
- 留空表示所有人都可以查看
- 角色名稱不區分大小寫

## 權限邏輯

1. **沒有設定 roles**：所有人都可以查看文件
2. **設定了 roles**：
   - 未登入使用者無法查看
   - 只有擁有指定角色的使用者可以查看
   - admin 角色可以查看所有文件

## API 使用

### 檢查權限

```ruby
doc = Docmd::Doc.find('my-document')

# 檢查使用者是否有權限查看
doc.accessible_by?(current_user)  # => true/false

# 取得文件的權限角色
doc.roles  # => ["admin", "editor"]
```

### 在控制器中使用

控制器會自動進行權限檢查：

```ruby
# DocsController 自動處理：
# - index: 只顯示使用者有權限的文件
# - show: 無權限時重導向並顯示提示訊息
```

## 整合範例

### 設定管理員

```ruby
# 建立管理員使用者
admin = User.create(email: 'admin@example.com', password: 'password')
admin.add_role :admin

# 管理員可以查看所有文件，包括有角色限制的
```

### 設定編輯者

```ruby
# 建立編輯者使用者
editor = User.create(email: 'editor@example.com', password: 'password')
editor.add_role :editor

# 編輯者只能查看：
# 1. 沒有角色限制的文件
# 2. roles 包含 "editor" 的文件
```

### 設定一般會員

```ruby
# 建立會員使用者
member = User.create(email: 'member@example.com', password: 'password')
member.add_role :member

# 會員只能查看：
# 1. 沒有角色限制的文件
# 2. roles 包含 "member" 的文件
```

## 注意事項

1. **current_user 方法**：主應用程式需要提供 `current_user` 方法（通常由 Devise 或其他認證 gem 提供）
2. **向下相容**：如果主應用程式沒有安裝 rolify 或使用者模型不支援 `has_role?` 方法，權限功能會自動停用
3. **效能考量**：建議為 roles 表建立適當的索引以優化查詢效能
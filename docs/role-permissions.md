# 角色權限功能

Docmd 支援基於角色的權限控制系統，可與主應用程式的 [rolify](https://github.com/RolifyCommunity/rolify) gem 整合。

## 功能特點

- 可設定哪些角色可以查看特定文件
- 與主應用程式的使用者系統整合
- 可配置的最高權限角色（預設為 admin 和 super_admin）
- 向下相容：如果主應用程式沒有 rolify，功能會自動停用

## 前置需求

### 1. 主應用程式安裝 rolify

[rolify README](https://github.com/RolifyCommunity/rolify?tab=readme-ov-file#rolify----)

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
   - 擁有最高權限角色的使用者可以查看所有文件

## 配置最高權限角色

在 `config/initializers/docmd.rb` 中設定：

```ruby
Docmd.configure do |config|
  # 預設的最高權限角色
  config.admin_roles = [:admin, :super_admin]

  # 根據專案需求自訂
  config.admin_roles = [:root]  # 只有 root
  config.admin_roles = [:admin, :manager]  # 多個角色
  config.admin_roles = []  # 沒有最高權限角色
end
```

擁有最高權限角色的使用者：
- 可以查看所有文件（無視文件的角色限制）
- 適合用於系統管理員、超級使用者等角色

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

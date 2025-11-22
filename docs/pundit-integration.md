# Pundit 整合指南

本指南說明 Docmd 如何整合 Pundit 進行權限管理。

## 快速摘要

- **未公開文件（草稿）**：只有管理員可以查看和編輯
- **已公開文件**：
  - 無角色限制：所有人可見
  - 有角色限制：需登入且擁有指定角色
- **管理操作**：新增、編輯、刪除文件需要管理員權限

## 內建 Policy

Docmd 已經內建了預設的 Pundit Policy，您可以直接使用或覆寫它。

### 預設權限規則

#### 文件權限 (DocPolicy)

Docmd 提供的預設 `Docmd::DocPolicy` 規則：
- **查看文件**：
  - 未公開（草稿）的文件：只有管理員可以查看
  - 已公開的文件：
    - 沒有角色限制的文件所有人都可看
    - 有角色限制的需要登入且擁有對應角色
- **新增/編輯/刪除**：只有管理員可以執行（由 `config.admin_roles` 設定）

#### 圖片權限 (ImagePolicy)

Docmd 提供的預設 `Docmd::ImagePolicy` 規則：
- **所有操作**：只有管理員可以執行
  - 查看圖片列表 (index)
  - 查看圖片 (show)
  - 上傳新圖片 (new/create)
  - 刪除圖片 (destroy)
  - 圖片選擇器 (insert)
- **權限檢查**：所有圖片相關頁面都需要管理員權限

## 自訂 Policy

如果預設規則不符合需求，您可以在主應用程式覆寫：

### 1. 建立自訂 Policy

可在主應用程式建立 `app/policies/docmd/doc_policy.rb` 來覆寫預設規則：

```ruby
# app/policies/docmd/doc_policy.rb
module Docmd
  class DocPolicy < ApplicationPolicy
    def show?
      # 自訂您的顯示權限邏輯

      # 未公開的文件只有管理員可以看
      return admin? if !doc.published?

      # 公開文件的權限檢查
      return true if doc.roles.empty?  # 沒有角色限制的公開文件
      return false unless user         # 需要登入

      # 使用 rolify 檢查角色
      if user.has_role?(:admin)
        true
      else
        doc.roles.any? { |role| user.has_role?(role.to_sym) }
      end
    end

    def edit?
      # 只有編輯者和管理員可以編輯
      user && (user.has_role?(:admin) || user.has_role?(:editor))
    end

    # ... 其他方法
  end
end
```

### 2. 自訂圖片權限

如果需要調整圖片權限（例如：允許編輯者上傳圖片），可建立 `app/policies/docmd/image_policy.rb`：

```ruby
# app/policies/docmd/image_policy.rb
module Docmd
  class ImagePolicy < ApplicationPolicy
    def index?
      # 允許編輯者查看圖片列表
      user && (admin? || editor?)
    end

    def create?
      # 允許編輯者上傳圖片
      user && (admin? || editor?)
    end

    def destroy?
      # 只有管理員可以刪除圖片
      admin?
    end

    private

    def editor?
      user.has_role?(:editor)
    end

    def admin?
      admin_roles = Docmd.configuration.admin_roles || [:admin, :super_admin]
      admin_roles.any? { |role| user.has_role?(role) }
    end
  end
end
```

## 權限規則說明

Docmd 的 DocsController 會在以下情況使用 Pundit：

| 動作 | Policy 方法 | 預設行為 |
|------|------------|---------|
| index | `show?` (每個文件) | 過濾列表，只顯示有權限的文件 |
| show | `show?` | 檢查使用者是否可以查看文件 |
| new | `new?` | 檢查使用者是否可以建立新文件 |
| create | `create?` | 檢查使用者是否可以儲存新文件 |
| edit | `edit?` | 檢查使用者是否可以編輯文件 |
| update | `update?` | 檢查使用者是否可以更新文件 |
| destroy | `destroy?` | 檢查使用者是否可以刪除文件 |
| preview | `new?` | 使用與建立相同的權限 |

## 與 Rolify 整合

在 Policy 中使用 rolify 來檢查角色：

```ruby
def admin?
  # 使用 Docmd 設定的管理員角色
  admin_roles = Docmd.configuration.admin_roles
  admin_roles.any? { |role| user.has_role?(role) }
end

def editor?
  user.has_role?(:editor)
end

def can_view_doc?
  # 檢查文件的 roles metadata
  doc.roles.any? { |role| user.has_role?(role.to_sym) }
end
```

## 文件的可見性設定

### 發布狀態

在 Markdown 文件的 front matter 中設定發布狀態：

```markdown
---
title: 草稿文件
publish: false  # 設為 false 表示未公開，只有管理員可見
---

這份文件還在編輯中，只有管理員可以查看。
```

### 角色限制

在 Markdown 文件的 front matter 中設定所需角色：

```markdown
---
title: 內部文件
publish: true  # 已公開
roles: [employee, manager]  # 需要這些角色之一才能查看
---

這份文件只有 employee 或 manager 角色的使用者可以查看。
```

### 組合使用

```markdown
---
title: 機密文件
publish: false  # 未公開（草稿）
roles: [executive]  # 當發布後，只有 executive 可見
---

這份文件目前是草稿狀態，只有管理員可見。
發布後將只對 executive 角色開放。
```

## 測試權限

```ruby
# 在 Rails console 中測試
user = User.find(1)
doc = Docmd::Doc.find('my-doc')
policy = Docmd::DocPolicy.new(user, doc)

policy.show?    # 測試是否可以查看
policy.edit?    # 測試是否可以編輯
policy.destroy? # 測試是否可以刪除
```

## 注意事項

1. 如果主應用程式沒有定義 Pundit 或相關 Policy，Docmd 會允許所有操作
2. Policy 中的 `user` 可能是 nil（未登入使用者），請確保處理這種情況
3. 管理員角色可以在 Docmd 設定中自訂：
   ```ruby
   Docmd.configure do |config|
     config.admin_roles = [:admin, :super_admin, :root]
   end
   ```
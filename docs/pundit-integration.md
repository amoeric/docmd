# Pundit 整合指南

本指南說明 Docmd 如何整合 Pundit 進行權限管理。

## 內建 Policy

Docmd 已經內建了預設的 Pundit Policy，您可以直接使用或覆寫它。

### 預設權限規則

Docmd 提供的預設 `Docmd::DocPolicy` 規則：
- **查看文件**：沒有角色限制的文件所有人都可看；有角色限制的需要登入且擁有對應角色
- **新增/編輯/刪除**：只有管理員可以執行（由 `config.admin_roles` 設定）

## 自訂 Policy

如果預設規則不符合需求，您可以在主應用程式覆寫：

### 1. 建立自訂 Policy

在主應用程式建立 `app/policies/docmd/doc_policy.rb` 來覆寫預設規則：

```ruby
module Docmd
  class DocPolicy < ApplicationPolicy
    def show?
      # 自訂您的顯示權限邏輯
      return true if doc.roles.empty?  # 公開文件
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

## 文件的角色設定

在 Markdown 文件的 front matter 中設定所需角色：

```markdown
---
title: 內部文件
roles: [employee, manager]
---

這份文件只有 employee 或 manager 角色的使用者可以查看。
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
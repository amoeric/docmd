# 測試用的 User model
class User < ApplicationRecord
  # 模擬 rolify 的 has_role? 方法
  def has_role?(role)
    roles.include?(role.to_s)
  end

  def roles
    (self[:roles] || '').split(',').map(&:strip)
  end

  def roles=(value)
    self[:roles] = Array(value).join(',')
  end
end

require "test_helper"

class Docmd::TagPolicyTest < ActiveSupport::TestCase
  def setup
    setup_test_docs
    @admin = users(:admin)
    @regular_user = users(:regular_user)
    @premium_user = users(:premium_user)
  end

  def teardown
    reset_docmd_config
  end

  # === index? ===
  test "index? returns true for everyone" do
    assert Docmd::TagPolicy.new(nil, Docmd::Tag).index?
    assert Docmd::TagPolicy.new(@regular_user, Docmd::Tag).index?
    assert Docmd::TagPolicy.new(@admin, Docmd::Tag).index?
  end

  # === show? ===
  test "show? returns true for everyone" do
    tag = Docmd::Tag.find('public')
    assert Docmd::TagPolicy.new(nil, tag).show?
    assert Docmd::TagPolicy.new(@regular_user, tag).show?
    assert Docmd::TagPolicy.new(@admin, tag).show?
  end

  # === Scope ===
  test "Scope returns all tags for admin" do
    scope = Docmd::TagPolicy::Scope.new(@admin, Docmd::Tag).resolve
    tag_names = scope.map(&:name)

    assert_includes tag_names, 'public'
    assert_includes tag_names, 'draft'
    assert_includes tag_names, 'premium'
    assert_includes tag_names, 'member'
    assert_includes tag_names, 'test'
  end

  test "Scope returns only tags with visible documents for regular user" do
    scope = Docmd::TagPolicy::Scope.new(@regular_user, Docmd::Tag).resolve
    tag_names = scope.map(&:name)

    # regular_user 有 member 角色，可以看到 public, member, test 標籤
    assert_includes tag_names, 'public'
    assert_includes tag_names, 'member'
    assert_includes tag_names, 'test'

    # 不能看到只有 draft 或 premium 文件的標籤
    assert_not_includes tag_names, 'draft'
    assert_not_includes tag_names, 'premium'
  end

  test "Scope returns only tags with public documents for unauthenticated user" do
    scope = Docmd::TagPolicy::Scope.new(nil, Docmd::Tag).resolve
    tag_names = scope.map(&:name)

    # 未登入使用者只能看到有公開文件的標籤
    assert_includes tag_names, 'public'
    assert_includes tag_names, 'test'

    # 不能看到需要登入或有角色限制的標籤
    assert_not_includes tag_names, 'draft'
    assert_not_includes tag_names, 'premium'
    assert_not_includes tag_names, 'member'
  end

  test "Scope returns premium tags for premium user" do
    scope = Docmd::TagPolicy::Scope.new(@premium_user, Docmd::Tag).resolve
    tag_names = scope.map(&:name)

    assert_includes tag_names, 'premium'
    assert_includes tag_names, 'member'
  end
end

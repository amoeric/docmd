require "test_helper"

class Docmd::DocPolicyTest < ActiveSupport::TestCase
  def setup
    setup_test_docs
    @admin = users(:admin)
    @super_admin = users(:super_admin)
    @regular_user = users(:regular_user)
    @premium_user = users(:premium_user)
    @no_role_user = users(:no_role_user)

    @public_doc = Docmd::Doc.find('public-doc')
    @draft_doc = Docmd::Doc.find('draft-doc')
    @premium_doc = Docmd::Doc.find('premium-doc')
    @member_doc = Docmd::Doc.find('member-doc')
  end

  def teardown
    reset_docmd_config
  end

  # === index? ===
  test "index? returns true for everyone" do
    assert Docmd::DocPolicy.new(nil, Docmd::Doc).index?
    assert Docmd::DocPolicy.new(@regular_user, Docmd::Doc).index?
    assert Docmd::DocPolicy.new(@admin, Docmd::Doc).index?
  end

  # === show? for admin ===
  test "admin can see all documents including drafts" do
    assert Docmd::DocPolicy.new(@admin, @public_doc).show?
    assert Docmd::DocPolicy.new(@admin, @draft_doc).show?
    assert Docmd::DocPolicy.new(@admin, @premium_doc).show?
    assert Docmd::DocPolicy.new(@admin, @member_doc).show?
  end

  test "super_admin can see all documents including drafts" do
    assert Docmd::DocPolicy.new(@super_admin, @public_doc).show?
    assert Docmd::DocPolicy.new(@super_admin, @draft_doc).show?
    assert Docmd::DocPolicy.new(@super_admin, @premium_doc).show?
    assert Docmd::DocPolicy.new(@super_admin, @member_doc).show?
  end

  # === show? for regular users ===
  test "regular user can see public documents" do
    assert Docmd::DocPolicy.new(@regular_user, @public_doc).show?
  end

  test "regular user cannot see draft documents" do
    assert_not Docmd::DocPolicy.new(@regular_user, @draft_doc).show?
  end

  test "regular user can see member documents if they have member role" do
    assert Docmd::DocPolicy.new(@regular_user, @member_doc).show?
  end

  test "regular user cannot see premium documents without premium role" do
    assert_not Docmd::DocPolicy.new(@regular_user, @premium_doc).show?
  end

  test "premium user can see premium documents" do
    assert Docmd::DocPolicy.new(@premium_user, @premium_doc).show?
  end

  # === show? for unauthenticated users ===
  test "unauthenticated user can see public documents" do
    assert Docmd::DocPolicy.new(nil, @public_doc).show?
  end

  test "unauthenticated user cannot see draft documents" do
    assert_not Docmd::DocPolicy.new(nil, @draft_doc).show?
  end

  test "unauthenticated user cannot see role-restricted documents" do
    assert_not Docmd::DocPolicy.new(nil, @premium_doc).show?
    assert_not Docmd::DocPolicy.new(nil, @member_doc).show?
  end

  # === show? with allow_unauthenticated_access config ===
  test "unauthenticated user can see public docs when allow_unauthenticated_access is set" do
    Docmd.configuration.allow_unauthenticated_access = { docs: [:show] }

    assert Docmd::DocPolicy.new(nil, @public_doc).show?
    assert_not Docmd::DocPolicy.new(nil, @draft_doc).show?
    assert_not Docmd::DocPolicy.new(nil, @premium_doc).show?
  end

  # === new?, create?, edit?, update?, destroy? ===
  test "only admin can create documents" do
    assert Docmd::DocPolicy.new(@admin, Docmd::Doc.new).new?
    assert Docmd::DocPolicy.new(@super_admin, Docmd::Doc.new).new?
    assert_not Docmd::DocPolicy.new(@regular_user, Docmd::Doc.new).new?
    assert_not Docmd::DocPolicy.new(nil, Docmd::Doc.new).new?
  end

  test "only admin can edit documents" do
    assert Docmd::DocPolicy.new(@admin, @public_doc).edit?
    assert Docmd::DocPolicy.new(@super_admin, @public_doc).edit?
    assert_not Docmd::DocPolicy.new(@regular_user, @public_doc).edit?
    assert_not Docmd::DocPolicy.new(nil, @public_doc).edit?
  end

  test "only admin can destroy documents" do
    assert Docmd::DocPolicy.new(@admin, @public_doc).destroy?
    assert Docmd::DocPolicy.new(@super_admin, @public_doc).destroy?
    assert_not Docmd::DocPolicy.new(@regular_user, @public_doc).destroy?
    assert_not Docmd::DocPolicy.new(nil, @public_doc).destroy?
  end

  # === Scope ===
  test "Scope returns all documents for admin" do
    scope = Docmd::DocPolicy::Scope.new(@admin, Docmd::Doc).resolve
    slugs = scope.map(&:slug)
    assert_includes slugs, 'public-doc'
    assert_includes slugs, 'draft-doc'
    assert_includes slugs, 'premium-doc'
    assert_includes slugs, 'member-doc'
  end

  test "Scope returns only accessible documents for regular user" do
    scope = Docmd::DocPolicy::Scope.new(@regular_user, Docmd::Doc).resolve
    slugs = scope.map(&:slug)
    assert_includes slugs, 'public-doc'
    assert_includes slugs, 'member-doc'
    assert_not_includes slugs, 'draft-doc'
    assert_not_includes slugs, 'premium-doc'
  end

  test "Scope returns only public documents for unauthenticated user" do
    scope = Docmd::DocPolicy::Scope.new(nil, Docmd::Doc).resolve
    slugs = scope.map(&:slug)
    assert_includes slugs, 'public-doc'
    assert_not_includes slugs, 'draft-doc'
    assert_not_includes slugs, 'premium-doc'
    assert_not_includes slugs, 'member-doc'
  end
end

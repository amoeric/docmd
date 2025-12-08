require "test_helper"

class Docmd::ConfigurationTest < ActiveSupport::TestCase
  def teardown
    Docmd.reset_configuration!
  end

  test "has default markdown_folder_path" do
    assert_equal Rails.root.join('docs'), Docmd.configuration.markdown_folder_path
  end

  test "has default admin_roles" do
    assert_equal [:admin, :super_admin], Docmd.configuration.admin_roles
  end

  test "has default show_toc" do
    assert_equal true, Docmd.configuration.show_toc
  end

  test "has default allow_unauthenticated_access" do
    assert_equal({}, Docmd.configuration.allow_unauthenticated_access)
  end

  test "can configure markdown_folder_path" do
    Docmd.configure do |config|
      config.markdown_folder_path = '/custom/path'
    end

    assert_equal '/custom/path', Docmd.configuration.markdown_folder_path
  end

  test "can configure admin_roles" do
    Docmd.configure do |config|
      config.admin_roles = [:super_admin, :moderator]
    end

    assert_equal [:super_admin, :moderator], Docmd.configuration.admin_roles
  end

  test "can configure show_toc" do
    Docmd.configure do |config|
      config.show_toc = false
    end

    assert_equal false, Docmd.configuration.show_toc
  end

  test "can configure allow_unauthenticated_access with actions array" do
    Docmd.configure do |config|
      config.allow_unauthenticated_access = { docs: [:index, :show] }
    end

    assert_equal({ docs: [:index, :show] }, Docmd.configuration.allow_unauthenticated_access)
  end

  test "can configure allow_unauthenticated_access with :all" do
    Docmd.configure do |config|
      config.allow_unauthenticated_access = { tags: :all }
    end

    assert_equal({ tags: :all }, Docmd.configuration.allow_unauthenticated_access)
  end

  test "can configure multiple controllers" do
    Docmd.configure do |config|
      config.allow_unauthenticated_access = {
        docs: [:index, :show],
        tags: :all
      }
    end

    expected = { docs: [:index, :show], tags: :all }
    assert_equal expected, Docmd.configuration.allow_unauthenticated_access
  end

  test "reset_configuration! restores defaults" do
    Docmd.configure do |config|
      config.admin_roles = [:custom_role]
      config.show_toc = false
      config.allow_unauthenticated_access = { docs: :all }
    end

    Docmd.reset_configuration!

    assert_equal [:admin, :super_admin], Docmd.configuration.admin_roles
    assert_equal true, Docmd.configuration.show_toc
    assert_equal({}, Docmd.configuration.allow_unauthenticated_access)
  end
end

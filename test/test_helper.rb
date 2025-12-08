# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class ActiveSupport::TestCase
  # 設定測試用的 markdown 資料夾路徑
  def setup_test_docs
    Docmd.configuration.markdown_folder_path = Pathname.new(file_fixture_path).join('docs')
  end

  # 重設 Docmd 設定
  def reset_docmd_config
    Docmd.reset_configuration!
  end
end

class ActionDispatch::IntegrationTest
  include Docmd::Engine.routes.url_helpers

  def default_url_options
    { only_path: true }
  end

  # 模擬使用者登入
  def sign_in(user)
    @current_user = user
  end

  def sign_out
    @current_user = nil
  end
end

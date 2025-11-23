require 'rails/generators/base'

module Docmd
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Creates a Docmd initializer file in your Rails application"

      def copy_initializer
        template 'docmd.rb', 'config/initializers/docmd.rb'
      end

      def create_docs_folder
        empty_directory 'docs'
        empty_directory 'docs/assets'
        empty_directory 'docs/assets/images'
        create_file 'docs/.keep'
        create_file 'docs/assets/images/.keep'
      end

      def display_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
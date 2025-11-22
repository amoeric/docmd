require_relative "lib/docmd/version"

Gem::Specification.new do |spec|
  spec.name        = "docmd"
  spec.version     = Docmd::VERSION
  spec.authors     = [ "amoeric" ]
  spec.email       = [ "xeriok02390@gmail.com" ]
  spec.homepage    = "https://github.com/amoeric/docmd"
  spec.summary     = "A Rails engine for markdown-based documentation management."
  spec.description = "Docmd is a Rails engine that provides markdown document management with image uploads, tagging, and role-based access control using Pundit and Rolify."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/amoeric/docmd"
  spec.metadata["changelog_uri"] = "https://github.com/amoeric/docmd/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib,docs}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "redcarpet", "~> 3.6", ">= 3.6.1"
  spec.add_dependency "mini_mime", "~> 1.1"
  spec.add_dependency "rolify"
  spec.add_dependency "pundit"
end

require_relative "lib/docmd/version"

Gem::Specification.new do |spec|
  spec.name        = "docmd"
  spec.version     = Docmd::VERSION
  spec.authors     = [ "amoeric" ]
  spec.email       = [ "xeriok02390@gmail.com" ]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of Docmd."
  spec.description = "TODO: Description of Docmd."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.1"
  spec.add_dependency "tailwindcss-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "redcarpet", "~> 3.6", ">= 3.6.1"
  spec.add_dependency "mini_mime", "~> 1.1"
end

require "tailwindcss-rails"

namespace :tailwindcss do
  namespace :docmd do
    desc "Build Tailwind CSS for Docmd engine"
    task :build do
      command = [
        Tailwindcss::Ruby.executable.to_s,
        "--input", Docmd::Engine.root.join("app/assets/tailwind/docmd/application.css").to_s,
        "--output", Docmd::Engine.root.join("app/assets/builds/docmd/tailwind.css").to_s,
        "--cwd", Rails.root.to_s
      ]

      # Add minification in production
      command << "--minify" if Rails.env.production?

      puts "Building Tailwind CSS..."
      system(*command, exception: true)
    end

    desc "Watch and build Tailwind CSS for Docmd engine"
    task :watch do
      command = [
        Tailwindcss::Ruby.executable.to_s,
        "--input", Docmd::Engine.root.join("app/assets/tailwind/docmd/application.css").to_s,
        "--output", Docmd::Engine.root.join("app/assets/builds/docmd/tailwind.css").to_s,
        "--cwd", Rails.root.to_s,
        "--watch"
      ]

      puts "Watching Docmd Tailwind CSS..."
      system(*command)
    end
  end
end

# assets:precompileタスクに統合
# プリコンパイルの直前にEngineのTailwindCSSビルドを実行する。
Rake::Task["assets:precompile"].enhance([ "tailwindcss:docmd:build" ])
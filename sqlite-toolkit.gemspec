require_relative './lib/sqlite-toolkit/version'

Gem::Specification.new do |s|
  s.name        = 'sqlite-toolkit'
  s.version     = SQLiteToolkit::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'SQLite toolkit for Ruby apps'
  s.author      = 'Sharon Rosner'
  s.email       = 'sharon@noteflakes.com'
  s.files       = `git ls-files`.split
  s.metadata    = {
    "source_code_uri" => "https://github.com/ciconia/sqlite-toolkit",
    "homepage_uri" => "https://github.com/ciconia/sqlite-toolkit",
    "changelog_uri" => "https://github.com/ciconia/sqlite-toolkit/blob/master/CHANGELOG.md"
  }
  s.rdoc_options = ["--title", "sqlite-toolkit", "--main", "README.md"]
  s.extra_rdoc_files = ["README.md"]
  s.extensions = ["ext/polyphony/extconf.rb"]
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.6'

  s.add_runtime_dependency      'sqlite3',            '~>1.4.2'
  s.add_development_dependency  'minitest',           '5.13.0'
  s.add_development_dependency  'minitest-reporters', '1.4.2'
  end

Gem::Specification.new do |s|
  s.name = "textfile"
  s.version = "1.0.6"
  s.authors = ["Piers Chambers"]
  s.email = "piers@varyonic.com"

  s.summary     = "Set-like wrapper around GNU comm and related textfile utilities."
  s.description = "Set-like wrapper around GNU comm and related textfile utilities.\n\nA common use case is to identify differences between exported datasets where the datasets may exceed 100K rows and each row may exceed 4K characters."
  s.homepage    = "http://github.com/varyonic/textfile"
  s.license     = "MIT"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/textfile.rb",
    "test/helper.rb",
    "test/test_textfile.rb",
    "textfile.gemspec"
  ]

  s.add_development_dependency "minitest", '~> 5.0'
  s.add_development_dependency "rdoc", "~> 3.12"
end

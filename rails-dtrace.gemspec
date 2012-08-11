# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails-dtrace/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Saxby"]
  gem.email         = ["sax@livinginthepast.org"]
  gem.description   = %q{Turn ActiveSupport::Notification instruments into DTrace probes. This allows you to trace Rails apps.}
  gem.summary       = %q{Add DTrace probes to Rails}
  gem.homepage      = "https://github.com/sax/dtrace-rails"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| ::File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rails-dtrace"
  gem.require_paths = ["lib"]
  gem.version       = Dtrace::VERSION

  gem.add_dependency 'ruby-usdt'
  gem.add_development_dependency 'rspec'
end

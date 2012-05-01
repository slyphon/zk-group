# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zk-group/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Jonathan D. Simms"]
  s.email         = ["slyphon@gmail.com"]
  s.description   = %q{A Group abstraction on top of the high-level ZooKeeper library ZK}
  s.summary       = %q{
Provides Group-like behaviors such as listing members of a group, joining,
leaving, and notifications when group memberhsip changes
  
Part of the ZK project.
}
  s.homepage      = "https://github.com/slyphon/zk-group"

  s.add_runtime_dependency 'zk', '~> 1.1.0'

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = "zk-group"
  s.require_paths = ["lib"]
  s.version       = ZK::Group::VERSION
end

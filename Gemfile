source :rubygems

gem 'zk', :path => '~/zk'

gem 'pry', :group => [:development, :test]

group :test do
  gem 'rspec', '~> 2.8'
end

group :docs do
  gem 'yard', '~> 0.7.5'

  platform :mri_19 do
    gem 'redcarpet'
  end
end

# Specify your gem's dependencies in zk-group.gemspec
gemspec



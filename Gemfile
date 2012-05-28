source :rubygems

# git 'git://github.com/slyphon/zookeeper.git', :ref => '8dfdd6be' do
#     gem 'zookeeper', '>= 1.0.0.beta.1'
# end

git 'git://github.com/slyphon/zk', :ref => '41bfd35' do
  gem 'zk'
end

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



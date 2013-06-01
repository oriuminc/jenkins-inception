package "rubygems1.9.1"

%w( ruby irb erb testrb rdoc gem rake ).each do |name|
  path = ::File.join('/usr/bin', name)

  link path do
    to path + "1.9.1"
    action :create
  end
end

gem_package "compass"

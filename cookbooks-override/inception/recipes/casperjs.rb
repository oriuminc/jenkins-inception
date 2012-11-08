include_recipe "ark"
include_recipe "inception::phantomjs"

ark "casperjs" do
  url 'https://github.com/n1k0/casperjs/archive/1.0.0-RC4.tar.gz'
  version '1.0.0-RC4'
  has_binaries ['bin/casperjs']
  action :install
end

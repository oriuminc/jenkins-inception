include_recipe "ark"

ark "phantomjs" do
  url 'http://phantomjs.googlecode.com/files/phantomjs-1.7.0-linux-x86_64.tar.bz2'
  version '1.7.0'
  has_binaries ['bin/phantomjs']
  action :install
end

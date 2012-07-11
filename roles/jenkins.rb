current_dir = File.dirname(__FILE__)
# Import configs from YAML file.
yml = YAML.load_file "#{current_dir}/config.yml"

name "jenkins"
description "The base role for setting up the jenkins master with appropriate initial settings."
run_list(
  "role[base]",
  "role[mysql_server]",
  "recipe[php]",
  "recipe[php::module_curl]",
  "recipe[php::module_gd]",
  "recipe[php::module_mysql]",
  "recipe[php::module_apc]",
  "recipe[php::module_memcache]",
  "recipe[php::module_memcached]",
  "recipe[php::write_inis]",
  "recipe[drush::utils]",
  "recipe[drush::make]",
  "recipe[jenkins]",
  "recipe[jenkins::proxy_apache2]",
  "recipe[inception]"
)
default_attributes(
  "drush" => {
    "version" => "5.4.0",
  },
  # Import YAML config array directly into node object.
  "inception" => yml,
  "jenkins" => {
    "http_proxy" => {
      "variant" => "apache2",
      # Empty string disables http basic auth
      "basic_auth_password" => "",
    },
    "server" => {
      "host" => "0.0.0.0",
      "plugins" => [
        "ansicolor",
        "disk-usage",
        "git",
        "github",
        "github-api",
        "github-oauth",
        "greenballs",
        "jobConfigHistory",
        "pegdown-formatter",
        "project-description-setter",
        "token-macro",
        "ws-cleanup",
      ]
    }
  }
)

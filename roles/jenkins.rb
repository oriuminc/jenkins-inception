current_dir = File.dirname(__FILE__)
# Import configs from YAML file.
yml = YAML.load_file "#{current_dir}/../misc/config.yml"

name "jenkins"
description "The base role for setting up the jenkins master with appropriate initial settings."
run_list(
  "recipe[apt]",
  "recipe[git]",
  "recipe[zsh]",
  "recipe[user::data_bag]",
  "recipe[oh-my-zsh::shared]",
  "recipe[vim]",
  "recipe[php]",
  "recipe[php::module_curl]",
  "recipe[drush::utils]",
  "recipe[drush::make]",
  "recipe[jenkins]",
  "recipe[inception]"
)
default_attributes(
  "inception" => {
    "repo" => yml['repo'],
    "branch" => yml['branch'],
  },
  "jenkins" => {
    "server" => {
      "plugins" => [
        "ansicolor",
        "git",
        "github",
        "greenballs",
        "jobConfigHistory",
        "pegdown-formatter",
        "project-description-setter",
        "ws-cleanup",
      ]
    }
  },
  "ohmyzsh" => {
    "theme" => "robbyrussell",
  },
  "user" => {
    "default_shell" => "/bin/zsh",
    "ssh_keygen" => "false",
  },
  "users" => yml['users']
)

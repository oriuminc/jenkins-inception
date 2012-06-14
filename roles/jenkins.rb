current_dir = File.dirname(__FILE__)
# Import configs from YAML file.
yml = YAML.load_file "#{current_dir}/config.yml"

name "jenkins"
description "The base role for setting up the jenkins master with appropriate initial settings."
run_list(
  "recipe[apt]",
  "recipe[sudo]",
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
  "authorization" => {
    "sudo" => {
      # Note: Overridden in Vagrantfile so vagrant user never locked out.
      "passwordless" => true,
      "users" => yml['users'],
    }
  },
  # Import YAML config array directly into node object.
  "inception" => yml,
  "jenkins" => {
    "server" => {
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
  },
  "ohmyzsh" => {
    "theme" => "afowler",
  },
  "user" => {
    "default_shell" => "/bin/zsh",
    "ssh_keygen" => false,
  },
  "users" => yml['users']
)

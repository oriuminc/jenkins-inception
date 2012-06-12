{
  "name": "jenkins",
  "default_attributes": {
    "jenkins": {
      "server": {
        "plugins": [
          "ansicolor",
          "git",
          "github",
          "greenballs",
          "jobConfigHistory",
          "pegdown-formatter",
          "project-description-setter",
          "ws-cleanup"
        ]
      }
    },
    "ohmyzsh": {
      "theme": "robbyrussell"
    },
    "user": {
      "default_shell": "/bin/zsh",
      "ssh_keygen": "false"
    }
  },
  "json_class": "Chef::Role",
  "env_run_lists": {
  },
  "run_list": [
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
  ],
  "description": "The base role for setting up the jenkins master with appropriate initial settings.",
  "chef_type": "role",
  "override_attributes": {
  }
}

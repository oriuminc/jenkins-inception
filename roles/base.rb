current_dir = File.dirname(__FILE__)
# Import configs from YAML file.
yml = YAML.load_file "#{current_dir}/config.yml"

name "base"
description "The base role for servers."
run_list(
  "recipe[apt]",
  "recipe[sudo]",
  "recipe[git]",
  "recipe[zsh]",
  "recipe[user::data_bag]",
  "recipe[oh-my-zsh::shared]",
  "recipe[vim]"
)
default_attributes(
  "authorization" => {
    "sudo" => {
      # Note: Overridden in Vagrantfile so vagrant user never locked out.
      "passwordless" => true,
      "users" => yml['users'],
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

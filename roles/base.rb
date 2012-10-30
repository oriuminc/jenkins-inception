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
  "recipe[openssh]",
  "recipe[user::data_bag]",
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
  "openssh" => {
    "server" => {
      "password_authentication" => "no",
      "permit_root_login" => "no",
    },
  },
  "user" => {
    "default_shell" => "/bin/zsh",
    "ssh_keygen" => false,
    "use_plaintext" => true,
  },
  "users" => yml['users']
)

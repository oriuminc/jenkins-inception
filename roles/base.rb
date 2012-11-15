current_dir = File.dirname(__FILE__)
# Import configs from YAML file.
yml = YAML.load_file "#{current_dir}/config.yml"

::Chef::Role.send(:include, Chef::Mixin::Language)

name "base"
description "The base role for servers."
run_list(
  "recipe[apt]",
  "recipe[sudo]",
  "recipe[git]",
  "recipe[zsh]",
  "recipe[openssh]",
  "recipe[user::data_bag]",
  "recipe[oh-my-zsh::shared]",
  "recipe[vim]"
)
default_attributes({
  "authorization" => {
    "sudo" => {
      # Note: Overridden in Vagrantfile so vagrant user never locked out.
      "passwordless" => true,
      "users" => data_bag("users"),
    },
  },
  "ohmyzsh" => {
    "theme" => "afowler",
  },
  "openssh" => {
    "client" => {
      "strict_host_key_checking" => "no",
    },
    "server" => {
      "password_authentication" => "no",
      "permit_root_login" => "no",
    },
  },
  "user" => {
    "default_shell" => "/bin/zsh",
    "ssh_keygen" => false,
    "password" => yml['password'],
    "use_plaintext" => true,
  },
  "users" => data_bag("users"),
})

current_dir = File.dirname(__FILE__)
# Import configs from YAML file.
yml = YAML.load_file("#{current_dir}/config.yml")['inception']

# Allow databag search in role file.
::Chef::Role.send(:include, Chef::DSL::DataQuery)

name "base"
description "The base role for servers."
run_list(
  "recipe[apt]",
  "recipe[inception::profiler_handler]",
  "recipe[fail2ban]",
  "recipe[chef-solo-search]",
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
      "groups" => ["sysadmin"],
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

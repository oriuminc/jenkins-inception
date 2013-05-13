name "dev_tools"
description "Development tools for Jenkins server."
run_list(
  "recipe[bash]",
  "recipe[phpcs::drupal_standard]",
  "recipe[xserver]",
  "recipe[ark]",
  "recipe[inception::casperjs]",
)
default_attributes({
  :phpcs => {
    # Needs fix before bumping: http://drupal.org/node/1847170
    :version => "1.4.0",
    :coder_git_ref => "7.x-2.0-beta1",
  },
})

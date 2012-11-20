name "dev_tools"
description "Development tools for Jenkins server."
run_list(
  "recipe[phpcs::drupal_standard]",
  "recipe[xserver]",
  "recipe[inception::casperjs]",
)
default_attributes({
  :phpcs => {
    :coder_git_ref => "7.x-2.0-beta1",
  },
})

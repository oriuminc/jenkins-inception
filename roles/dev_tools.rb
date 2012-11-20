name "dev_tools"
description "Development tools for Jenkins server."
run_list(
  "recipe[phpcs::drupal_standard]",
  "recipe[xserver]",
  "recipe[inception::casperjs]",
)
default_attributes({
  :phpcs => {
    :coder_git_ref => "c43676c3909038addcc75bc2c10ef35a1db1f368",
  },
})

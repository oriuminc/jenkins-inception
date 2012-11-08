name "dev_tools"
description "Development tools for Jenkins server."
run_list(
  "recipe[xserver]",
  "recipe[inception::casperjs]",
)
default_attributes({
})

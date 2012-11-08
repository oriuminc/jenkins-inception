name "dev_tools"
description "Development tools for Jenkins server."
run_list(
  "recipe[inception::casperjs]",
)
default_attributes({
})

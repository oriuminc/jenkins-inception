name "dev_tools"
description "Development tools for Jenkins server."
run_list(
  "recipe[inception::phantomjs]",
)
default_attributes({
})

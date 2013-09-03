include_recipe "chef-solo-search"
node.set['users'] = data_bag("users")

include_recipe "user::data_bag"

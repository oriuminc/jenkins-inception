current_dir = File.dirname(__FILE__)

file_cache_path "/var/chef-solo"
cookbook_path [ "#{current_dir}/../cookbooks", "#{current_dir}/../cookbooks-override" ]
role_path "#{current_dir}/../roles"
data_bag_path "#{current_dir}/../data_bags"

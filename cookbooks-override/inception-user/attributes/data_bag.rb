set['user']['default_shell'] = "/bin/sh"
set['user']['ssh_keygen'] = false
set['user']['password'] = node['inception']['password']
set['user']['use_plaintext'] = true
set['user']['groups'] = ["sysadmin"]

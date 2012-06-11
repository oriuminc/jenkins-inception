Inception
=========

  - Source: https://github.com/myplanetdigital/inception

A Drupal continuous integration infrastructure in a box. This currently
includes:

  - Jenkins
  - Drush
  - PHP
  - a simple build job (configured via `misc/config.yml`)

**Inception is in active development at Myplanet Digital, and should be
considered alpha code. Stability and full documentation not yet
guaranteed.**

Goals
-----

Why don't most developers use continuous integration? We think it's
because it's hard to know where to start. We'd like to make it as simple
as entering your cloud provider credentials (Rackspace/AWS/whatever) and
running a single command.

Quickstart
----------

    $ curl -L get.rvm.io | bash -s 1.14.1
    $ source ~/.rvm/scripts/rvm
    $ git clone https://github.com/myplanetdigital/inception.git
    $ cd inception
    $ bundle exec librarian-chef install

Be sure to configure the settings in `misc/config.yml`.

The next steps vary based on how you'd like to launch the Inception
stack.

### Vagrant

If you have Vagrant installed, you can test the setup on local virtual
machines:

    $ bundle exec vagrant up  # Spin up the VM
    $ bundle exec vagrant ssh # SSH into the VM

You can now view the Jenkins UI at: http://localhost:8080

You can also access this virtual jenkins through the command-line by
running:

    $ bundle exec jenkins configure --host=localhost --port=8080
    $ bundle exec jenkins --help

### Cloud

If you have an Amazon Web Services or Rackspace account, there are
several ways to host Inception in the cloud (going from simplest to more
complex):

  - Provisioned as a standalone server with Chef Solo.
  - Provisioned as part of a hosted Chef Server setup via Opscode
    Platform.
  - Provisioned as part of a self-hosted Chef Server setup.

Keep in mind that you will need to self-host the Jenkins server
regardless. It is only the Chef Server hosting that varies: none,
hosted, or self-hosted. If you have no plans to expand your
infrastructure, provisioning a server via Chef Solo should work fine,
and there will be less overhead to worry about.

#### Stand-alone Chef Solo

Assuming you have received credentials for a fresh Rackspace server
running Ubuntu Lucid (IP and root password), run these commands:

    $ bundle exec ssh-forever root@<IP_ADDRESS> -i /path/to/ssh_key.pub -n jenkins-PROJECT
    $ # Enter root password when prompted.
    $ ssh jenkins-PROJECT "curl -L http://www.opscode.com/chef/install.sh | bash /dev/stdin -v 0.10.8-3"
    $ ssh jenkins-PROJECT "apt-get install rsync"
    $ rsync -avz cookbooks data_bags cookbooks-override roles misc jenkins-PROJECT:/tmp/chef-solo/
    $ ssh jenkins-test "chef-solo -c /tmp/chef-solo/misc/solo.rb -j /tmp/chef-solo/misc/solo-dna.json"

More coming soon...

#### Hosted via Opscode Platform

Opscode platform is a hosted Chef server that is free for managing up to
5 servers. This should be more than enough for each project-specific CI
setup.

We'll be including various Rake tasks to automate the setup process as
much as possible. These rake tasks will attempt to use a browser
webdriver to fill out web forms and perform simple setup tasks for you.

You may view the available tasks from the project root by running `rake
-D` (for full descriptions) or `rake -T` (for short descriptions)

More coming soon...

#### Self-hosted Chef Server

Coming soon...

Known Issues
------------

  - Seems that any restart of the VM causes Jenkins to be unavailable
    from the host, even though it's still running.
  - Jenkins package repository having issues for the past 2 days (as of
    June 11, 2012), where it's pointing to [a package that doesn't
    exist](http://mirrors.jenkins-ci.org/debian/jenkins_1.469_all.deb).
    Should be resolved soon.

To Do
-----

  - Create a chef server as a multi-VM Vagrant environment (or use
    [Hatch][hatch-project]?)
  - Provide instructions on using with Opscode hosted Chef server?
  - Use watir-webdriver and rake to create an opscode hosted chef
    account and/or create a new hosted chef organization.
  - Include a base Drupal install profile to show file structure and
    bare minimum scripting expectations.
  - Add [spiceweasel][spiceweasel-project] support for launching into
    the cloud.
  - Convert `jenkins.json` role to `jenkins.rb`, so that we can load
    `config.yml` as part of it, and simplify `solo-dna.json`.
  - Convert chef-solo provisioning steps to rake task.

<!-- Links -->
   [hatch-project]:       http://xdissent.github.com/chef-hatch-repo/
   [spiceweasel-project]: http://wiki.opscode.com/display/chef/Spiceweasel 

Inception
=========

* Source: https://github.com/myplanetdigital/inception

This project aims to be a Drupal continuous integration infrastructure
in a box. This will include:

  - Jenkins
  - Drush
  - PHP

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

The next steps vary based on how you'd like to launch the Inception
stack.

### Vagrant

If you have Vagrant installed, you can test the setup on local virtual
machines:

    $ bundle exec vagrant up  # Spin up the VM
    $ bundle exec vagrant ssh # SSH into the VM

You can now view the Jenkins UI at: http://localhost:8080

To Do
-----

* Add a `Vagrantfile` so that the setup can be testing locally. (use
  [Hatch][hatch-project]?)
* Provide instructions on using with Opscode hosted Chef server?

<!-- Links -->
   [hatch-project]: http://xdissent.github.com/chef-hatch-repo/

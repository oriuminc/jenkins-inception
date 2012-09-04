Inception
=========

  - Source: https://github.com/myplanetdigital/inception

A Drupal continuous integration infrastructure in a box. This currently
includes:

  - Jenkins
  - Drush
  - PHP
  - a simple build job (configured via `roles/config.yml`)

**Inception is in active development at Myplanet Digital, and should be
considered alpha code. Stability and full documentation not yet
guaranteed.**

Goals
-----

Why don't most developers use continuous integration? We think it's
because it's hard to know where to start. We'd like to make it as simple
as entering your cloud provider credentials (Rackspace/AWS/whatever) and
running a single command.

We'll be building this out based on a set of assumptions regarding how
to best build a Drupal site. This set of assumptions will take the form
of the [2nd Level Deep][2ndleveldeep] install profile. The goal will be
build a totally self-contained base profile, which other projects can
use as a foundation. Ideally, only slight configurations of the Jenkins
CI environment (ie. project name, and git repo URL) will be needed in
order to build any project that uses the 2nd Level Deep install profile.

Features
--------

  - Jenkins integration with Github project via commit links.
  - [Authentications via GitHub credentials.][plugin-github-oauth]
    Anyone in a specified GitHub organization will be given access to
    the Jenkins UI. **This will not work locally on Vagrant.**
  - Various [rake][about-rake] tasks for helping with everything from
    fixing Vagrant networking issues to automating the webform signup
    for Opscode Platform. Type `rake -D` or `rake -T` to see available
    tasks.
  - Configured to boot the base demo of 2nd Level Deep install profile,
    right off the bat.

Quickstart
----------

### Setup

    $ curl -L get.rvm.io | bash -s 1.14.12
    $ source $HOME/.rvm/scripts/rvm
    $ rvm reload
    $ git clone git@github.com:myplanetdigital/inception.git
    $ cd inception
    $ gem regenerate_binstubs
    $ librarian-chef install

### Configuration

While the default demo stack will boot without any custom configuration, you'll
likely want to tailor it to your needs.

  - Configure the build job settings in `roles/config.yml`. You'll need
    to register a GitHub application in order to enter credentials.
  - Customize the `data_bags/users` entries, which will be used by the
    [`user` cookbook][user-cookbook] to set up linux users with SSH
keys.  A sample entry `patcon.json` is provided. There is a rake task
available to help you generate your own encrypted passwords. Please see
the cookbook documentation for more advanced configuration. I enjoy
access to random machines, so please feel free to deploy my keys.

The next steps vary based on how you'd like to launch the Inception
stack.

### Vagrant

If you have Vagrant installed, you can test the setup on local virtual
machines:

    $ vagrant up  # Spin up the VM
    $ vagrant ssh # SSH into the VM

You can now view the Jenkins UI at: http://localhost:8080

A built site can be viewed at: http://JOB_NAME.inception.dev:8080

Currently, the latter requires adding entries to your host machine's
`/etc/hosts` file. (ie. `127.0.0.1 build-int.inception.dev`)

Please see the [known issue](#known-issues) below regarding problems
with Jenkins when restarting the VM with `vagrant reload`.

You can also access this virtual jenkins through the command-line by
running:

    $ jenkins configure --host=localhost --port=8080
    $ jenkins --help

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

Assuming you have received credentials (root password and IP address)
for a fresh server running Ubuntu Lucid, run these commands substituting
an appropriate PROJECT name and IP_ADDRESS:

    $ echo -e "\nHost jenkins-PROJECT\n  User root\n  HostName IP_ADDRESS" >> ~/.ssh/config
    $ ssh-forever jenkins-PROJECT -i path/to/ssh_key.pub # Enter root password when prompted.
    $ # Install Chef on the server
    $ knife prepare jenkins-PROJECT --omnibus-version 10.12.0-1
    $ # Run chef-solo on jenkins-PROJECT server
    $ knife cook jenkins-PROJECT nodes/jenkins.json --skip-syntax-check --skip-chef-check

**Notes:** The [chef-solo-search][chef-solo-search] cookbook is simply a
container for a library that allows for chef-server search functions
that are not available in native chef-solo. See that project's README
for documentation.

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

Notes
-----

  - When GitHub authentication isn't set up, Jenkins will use the Unix
    user database from the server itself, which is set up based on the
    `users` databag entries with passwords. Use the rake task provided to
    encrypt your plaintext password. After you put the encrypted version in
    the databag, then you'll be able to log into Jenkins with the plaintext
    one.
  - We also store the plaintext password in the databag as
    `password_plaintext`. This is a bit of a hack, but without getting
    into the details, you'll need at least one user that has this key, so
    that Chef can use it to update build jobs.

Known Issues
------------

  - Currently, every entry in the `users` databag that uses `zsh` must
    be enabled in the `users` entry of `config.yml`, or there will be an
    ohmyzsh-related error during chef run.
  - When using GitHub authorization, there is [an outstanding
    issue][github-auth-issue] that prevents us from authorizing
    programmatically, and therefore Chef cannot run authorized actions like
    updating builds. GitHub auth not recommended until this is fixed.
  - Chef only defines MySQL passwords for the Vagrant VM, which means
    that it's not yet ready to run on a cloud server. Removing
    `role[mysql_server]` from the `roles/jenkins.rb` should negate the issue
    in the meantime.
  - Every once in awhile, ruby 1.8.7 in the VM will throw a
    segmentation fault while installing `libmysql-ruby` during the chef
    run. It's sporadic, and reprovisioning should move past it.
  - LogMeIn Hamachi is known to cause issues with making `pear.php.net`
    unreachable, and so the environment won't build.
  - Generally, both ruby and its gems should be compiled using the same
    version of Xcode. If you get odd errors, remove ruby and its gems
    and recompile.

To Do
-----

  - In order to update jenkins jobs, must have a small recipe to
    authenticate with the jenkins_cli resource.
  - Include a base Drupal install profile to show file structure and
    bare minimum scripting expectations.
  - Currently, oh-my-zsh cookbook fails if user databag entry exists
    which is not "enabled". Submit a patch to account for the cases
    where this is untrue.
  - Look into better alternative to `0.0.0.0` for
    `node['jenkins']['server']['host']`
  - Add feature to create DNS a-record if DynDNS API credentials are
    supplied in `config.yml`.
  - Add recommendation for gcc-isntaller rather than xcode?
  - Add note on port forwarding 8080. (:auto?)
  - Figure out bundler issue in rvmrc by starting fresh (Yash's compy).
    Might NOT work on Lion for now.
  - Investigate [knife-solo gem](https://github.com/matschaffer/knife-solo).
  - Create rake task for chef-solo setup steps?
  - replace ssh-forever with straighy-up rake task or cap?
  - Add [spiceweasel][spiceweasel-project] support for launching into
    the cloud when using chef-server.
  - Provide instructions on using with Opscode hosted Chef server?
  - Use watir-webdriver and rake to create an opscode hosted chef
    account and/or create a new hosted chef organization.
  - Create a chef server as a multi-VM Vagrant environment (or use
    [Hatch][hatch-project]?)
  - Investigate using [preSCMbuildstep plugin][plugin-preSCMbuildstep]
    for running `jenkins-setup.sh`
  - Put jenkins user under databag control.
  - Investigate [hosted chef gem][hosted-chef-gem].
  - Add `admin` user, which will be used for authenticating Chef during
    actions that require authorization.
  - Test whether github auth can work with localhost.
  - Hack chef-user cookbook to allow for plaintext passwords, rather
    than just shadow hash of password.
  - Create role hierarchy like in Ariadne.
  - Set up varnish.
  - Submit PR to knife-solo to prevent auto-creation of node.json.

<!-- Links -->
   [hatch-project]:            http://xdissent.github.com/chef-hatch-repo/
   [spiceweasel-project]:      http://wiki.opscode.com/display/chef/Spiceweasel
   [chef-solo-search]:         https://github.com/edelight/chef-solo-search#readme
   [user-cookbook]:            https://github.com/fnichol/chef-user#readme
   [plugin-github-oauth]:      https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin
   [plugin-preSCMbuildstep]:   https://wiki.jenkins-ci.org/display/JENKINS/pre-scm-buildstep
   [about-rake]:               http://en.wikipedia.org/wiki/Rake_(software)
   [2ndleveldeep]:             https://github.com/myplanetdigital/2ndleveldeep#readme
   [hosted-chef-gem]:          https://github.com/opscode/hosted-chef-gem#readme
   [github-auth-issue]:        https://github.com/mocleiri/github-oauth-plugin/issues/18

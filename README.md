Inception
=========

**Current status: UNSTABLE.** (We use the tool internally at Myplanet, but
there are several undocumented steps that we take to massage the system
into a running state.)

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
  - Testing tools configured:
    - PhantomJS
    - CasperJS
    - Xserver Virtual Framebuffer (xvfb)

Quickstart
----------

### Setup (RVM)

    curl -L get.rvm.io | bash -s 1.14.12
    exec $SHELL
    git clone git@github.com:myplanetdigital/jenkins-inception.git
    cd jenkins-inception
    gem regenerate_binstubs
    librarian-chef install

### Setup (rbenv -- incomplete)

    # TODO: Document rbenv setup
    git clone git@github.com:myplanetdigital/jenkins-inception.git
    cd jenkins-inception
    bundle install --path tmp/bundler
    rbenv rehash
    librarian-chef install

### Configuration

The first thing you'll want to do is generate a `config.yml` template:

    rake init

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

    vagrant up  # Spin up the VM
    vagrant ssh # SSH into the VM

You can now view the Jenkins UI at: http://localhost:8080

A built site can be viewed at: http://JOB_NAME.inception.dev:8080

Currently, the latter requires adding entries to your host machine's
`/etc/hosts` file. (ie. `127.0.0.1 build-int.inception.dev`)

Please see the [known issue](#known-issues) below regarding problems
with Jenkins when restarting the VM with `vagrant reload`.

You can also access this virtual jenkins through the command-line by
running:

    jenkins configure --host=localhost --port=8080
    jenkins --help

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

The first thing you'll want to do is edit the `domain` key in the
`roles/config.yml`. This is where Jenkins will be served, either by
pointing a DNS A-record at the server, or by adding a line like this to
your `/etc/hosts` file. If you set the `domain` value in `config.yml` to
be `ci.example.com`, this is what you would use in your `hosts` file:

    # <SERVER_IP_ADDRESS> <JENKINS_URL> <JOB1_DOCROOT_URL> ...
    123.123.123.123 ci.example.com build-int.ci.example.com

Jenkins will be available at `http://ci.example.com`, and the
"build-int" Jenkins job docroot (the only one provided by default), will
be served at `http://build-int.ci.example.com`. (If using an A-record,
you'd likely want to create one for each of `ci.example.com` and
`*.ci.example.com`, so any future job docroots would be served
correctly.)

Assuming you have received credentials (root password and IP address)
for a fresh server running Ubuntu Lucid, run the commands below, substituting
appropriate environment variables.

    export INCEPTION_PROJECT=projectname
    export INCEPTION_USER=patcon # Your username from the users data bag
    export INCEPTION_IP=123.45.67.89
    echo -e "\nHost $INCEPTION_PROJECT\n  User $INCEPTION_USER\n  HostName $INCEPTION_IP" >> ~/.ssh/config
    ssh-forever root@$INCEPTION_PROJECT -i path/to/ssh_key.pub # Enter root password when prompted.
    knife prepare root@$INCEPTION_PROJECT --omnibus-version 10.16.2-1
    knife cook root@$INCEPTION_PROJECT nodes/jenkins.json --skip-chef-check

# Subsequent chef-solo runs will employ user.
knife cook $INCEPTION_PROJECT nodes/jenkins.json --skip-chef-check

**Notes:** The [chef-solo-search][chef-solo-search] cookbook is simply a
container for a library that allows for chef-server search functions
that are not available in native chef-solo. See that project's README
for documentation.

To have Jenkins work with GitHub via its GitHub plugin, you'll need to
go to your GitHub repo admin page and add the "Service Hook" for
"Jenkins (GitHub plugin)", using the admin user credentials (which we
happen to pull from our `users` data bag within Inception):

    http://patcon:sekret@ci.example.com/github-webhook

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
    `users` databag entries with passwords.

Known Issues
------------

  - When using GitHub authorization, there is [an outstanding
    issue][github-auth-issue] that prevents us from authorizing
    programmatically, and therefore Chef cannot run authorized actions like
    updating builds. GitHub auth not recommended until this is fixed.
  - Every once in awhile, ruby 1.8.7 in the VM will throw a
    segmentation fault while installing `libmysql-ruby` during the chef
    run. It's sporadic, and reprovisioning should move past it.
  - LogMeIn Hamachi is known to cause issues with making `pear.php.net`
    unreachable, and so the environment won't build.
  - Generally, both ruby and its gems should be compiled using the same
    version of Xcode. If you get odd errors, remove ruby and its gems
    and recompile.
  - For some reason, jenkins_cli LWRP is needed for login on Vagrant VM,
    but causes chef run failure when using knife-solo with rackspace. Have
    workaround in place, but should probably investigate why this might be.

To Do
-----

  - In order to update jenkins jobs, must have a small recipe to
    authenticate with the jenkins_cli resource.
  - Include a base Drupal install profile to show file structure and
    bare minimum scripting expectations.
  - Look into better alternative to `0.0.0.0` for
    `node['jenkins']['server']['host']`
  - Add feature to create DNS a-record if DynDNS API credentials are
    supplied in `config.yml`.
  - Add note on port forwarding 8080. (:auto?)
  - Investigate [knife-solo gem](https://github.com/matschaffer/knife-solo).
  - Create rake task for chef-solo setup steps?
  - Add [spiceweasel][spiceweasel-project] support for launching into
    the cloud when using chef-server.
  - Provide instructions on using with Opscode hosted Chef server?
  - Use watir-webdriver and rake to create an opscode hosted chef
    account and/or create a new hosted chef organization.
  - Create a chef server as a multi-VM Vagrant environment (or use
    [Hatch][hatch-project]?)
  - Investigate using [preSCMbuildstep plugin][plugin-preSCMbuildstep]
    for running `jenkins-setup.sh`
  - Investigate [hosted chef gem][hosted-chef-gem].
  - Test whether github auth can work with localhost.
  - Create role hierarchy like in Ariadne.
  - Set up varnish.
  - Submit PR to knife-solo to prevent auto-creation of node.json.
  - Determine public vs private git repo and change job git url
    accordingly.

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

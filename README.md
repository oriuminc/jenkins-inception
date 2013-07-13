Inception
=========

![Build pipeline
screenshot](http://i.imgur.com/GUqYKNZ.png)

**Current status: STABLE BUT UNDOCUMENTED.** (We use the tool internally
at Myplanet, but still need to document features and assumptions.)

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
of the [Skeletor][skeletor] install profile skeleton. The goal will be
build a totally self-contained base profile, which other projects can
use as a foundation. Ideally, only slight configurations of the Jenkins
CI environment (ie. project name, and git repo URL) will be needed in
order to build any project that uses the Skeletor install profile as
a base.

Features
--------

  - Jenkins integration with Github project via commit links.
  - [Authentications via GitHub credentials.][plugin-github-oauth]
    Anyone in a specified GitHub organization will be given access to
    the Jenkins UI. **This will not work locally on Vagrant.**
  - Various [rake][about-rake] tasks for helping with everything from
    creating new Rackspace servers to adding GitHub service hooks. Type
    `rake -D` or `rake -T` to see available tasks.
  - Configured to boot the base demo of Skeletor install profile,
    right off the bat.
  - Testing tools configured:
    - PhantomJS
    - CasperJS
    - Xserver Virtual Framebuffer (xvfb)

Quickstart
----------

- Install Xcode with Command Line Tools from Apple Developer website.

        git clone https://github.com/myplanetdigital/jenkins-inception.git
        cd jenkins-inception
        [sudo] gem install bundler
        bundle install
        bundle exec rake team:configure
        bundle exec rake team:generate_users
        bundle exec rake team:fork_skeletor
        bundle exec rake admin:create_subdomain
        bundle exec vagrant up
        # Temporary fixed until GH-27 solved.
        ssh <github_username>@ci.myproject.example.com "sudo -iujenkins ssh-keygen -t rsa -C jenkins@localhost"
        bundle exec rake team:add_deploy_key
        bundle exec rake team:service_hook

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

To Do
-----

  - Include a base Drupal install profile to show file structure and
    bare minimum scripting expectations.
  - Add feature to create DNS a-record if DynDNS API credentials are
    supplied in `config.yml`.
  - Add note on port forwarding 8080. (:auto?)
  - Add [spiceweasel][spiceweasel-project] support for launching into
    the cloud when using chef-server.
  - Provide instructions on using with Opscode hosted Chef server?
  - Create a chef server as a multi-VM Vagrant environment (or use
    [Hatch][hatch-project]?)
  - Investigate using [preSCMbuildstep plugin][plugin-preSCMbuildstep]
    for running `jenkins-setup.sh`
  - Investigate [hosted chef gem][hosted-chef-gem].
  - Create role hierarchy like in Ariadne.
  - Set up varnish.
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
   [skeletor]:                 https://github.com/myplanetdigital/drupal-skeletor/blob/master/SKELETOR-README.md
   [hosted-chef-gem]:          https://github.com/opscode/hosted-chef-gem#readme
   [github-auth-issue]:        https://github.com/mocleiri/github-oauth-plugin/issues/18

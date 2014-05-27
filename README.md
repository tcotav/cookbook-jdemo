
![Level 11](Level11.png)
## Creating a new cookbook with ChefDK  

### Overview

We're going to build a simple cookbook to support installing tomcat on an ubuntu server.  We're going to try to keep our environment as self-contained as possible for now.

You'll need to:

  - get `git`  (os dependent)
  - [get Chef DK](http://www.getchef.com/downloads/chef-dk/)
  - [get Virtualbox](http://virtualbox.org)
  - [get Vagrant](http://vagrantup.com)

These tools will enable us to stay local with our cookbook convergence testing.

### Get your project started using new `chef` command

We're going to first generate a new cookbook.

    $ chef generate cookbook jdemo
  
Lots of files generated for us with this command.  Let's take a quick look at what we've got.
    
    $ ls jdemo
    Berksfile	README.md	chefignore	metadata.rb	recipes
    
There's some hidden files in there too though.  

    $ ls -la jdemo
    total 40
    drwxr-xr-x  8 james  staff  272 May 12 09:18 .
    drwxr-xr-x  5 james  staff  170 May 12 09:23 ..
    -rw-r--r--  1 james  staff  202 May 12 09:18 .kitchen.yml  <<<--- like this guy.  we'll look at it later.
    -rw-r--r--  1 james  staff   45 May 12 09:18 Berksfile
    -rw-r--r--  1 james  staff   60 May 12 09:18 README.md
    -rw-r--r--  1 james  staff  985 May 12 09:18 chefignore
    -rw-r--r--  1 james  staff  201 May 12 09:18 metadata.rb
    drwxr-xr-x  3 james  staff  102 May 12 09:18 recipes
    
 
So now we're ready to do something.

### Installing necessary cookbooks

Our goal is to install tomcat on a host.  There exists a public opscode `tomcat` cookbook that we're going to grab and apply to our host.  

We'll add the `tomcat` cookbook in two steps.  First we need to pull the source cookbook into our environment, and then second, we need to tell chef that we want to use it.
 
### Enter Berkshelf

Berkshelf is a tool to manage a cookbook or application's depedencies.  It now is shipped as part of `chefdk`.

To use Berkshelf, we will edit the file in the cookbook root named `Berksfile`.  This is a file used to tell Berkshelf what cookbooks it is expected to manage.

Open it and you'll see the following:
    
    source "https://api.berkshelf.com"
    
    metadata

What this tells chef is that the Berkshelf tool will defer to the `metadata.rb` file for information as to what external cookbooks our cookbook utilizes.  Think of it as a reference telling chef "go look in `metadata.rb` for the dependencies."

Our next step then is to edit `metadata.rb`.  As a newly gen'd file, `metadata.rb` looks like this.  We're going to add lines at the end.

    name             'jdemo'
    maintainer       ''
    maintainer_email ''
    license          ''
    description      'Installs/Configures jdemo'
    long_description 'Installs/Configures jdemo'
    version          '0.1.0'

At the end of this file, we're going to add two lines:
 
    depends "apt"
    depends "tomcat"

   
Save the file.  Now's a really good time to get this stuff into git.  Initialize the directory and then check EVERYTHING in.  

    $ git init
    $ git add -A
    $ git commit -m "initial commit"
    
Those are the commands.  This is what you should see (-ish) when you run them.
        
     $ git status
     # On branch master
     #
     # Initial commit
     #
     # Changes to be committed:
     #   (use "git rm --cached <file>..." to unstage)
     #
     #	new file:   .kitchen.yml
     #	new file:   Berksfile
     #	new file:   README.md
     #	new file:   Vagrantfile
     #	new file:   chefignore
     #	new file:   metadata.rb
     #	new file:   recipes/default.rb
     #
     jdemo james$ git commit -m "initial commit"
     [master (root-commit) 8b0819f] initial commit
      7 files changed, 205 insertions(+)
      create mode 100644 .kitchen.yml
      create mode 100644 Berksfile
      create mode 100644 README.md
      create mode 100644 Vagrantfile
      create mode 100644 chefignore
      create mode 100644 metadata.rb
      create mode 100644 recipes/default.rb

### Berks -- grab the cookbooks 

In the last step, we put together all the config we needed to grab the files from the magical intarwubz, but we didn't actually do the retrieving.    To do that, type the command `berks` while in the base cookbook directory (same directory as the `Berksfile`):
    
    $ berks
    Resolving cookbook dependencies...
    Fetching 'jdemo' from source at .
    Fetching cookbook index from https://api.berkshelf.com...
    Using apt (2.3.10)
    Using java (1.22.0)
    Using openssl (1.1.0)
    Using jdemo (0.1.0) from source at .
    Using tomcat (0.15.12)    

This goes out and grabs all of the cookbooks that we need and puts them in a secret location (`~/.berkshelf/cookbooks` actually -- you can see the cookbooks in there if you want to do a `ls`).
       
### Kitchen
     
Now we want to try converging our node.  We could use hosted enterprise chef for our Chef server and then test against a node that we spun up.  Instead, for this demo we'll use chef solo and the capabilities of another piece of `chefdk` -- test kitchen.  We'll only be using a little bit of it to drive chef solo node convergence.  We'll leave testing off for another time.

To use it, we're going to make a quick edit to the config file for kitchen that tells it what VMs to spin up.  

`.kitchen.yml`

    ---
    driver:
      name: vagrant
    
    provisioner:
      name: chef_solo
    
    platforms:
      - name: ubuntu-12.04
      - name: centos-6.4
    
    suites:
      - name: default
        run_list:
          - recipe[bar::default]
        attributes:

That's what the default gen'd file looks like.  It is going to spin up TWO virtual machines as is listed in the `platforms` section.  For this demo, we're only going to use one.  Remove the line for centos.  The other change is to tell the node what chef resources to use.  This idea is called a `run list` in chef parlance.  Here we want it to kick off a file that we haven't touched yet namely `recipes/default.rb`.  You see below the run list section and in that we've changed the placeholder `bar::default`

    ---
    driver:
      name: vagrant
    
    provisioner:
      name: chef_solo
    
    platforms:
      - name: ubuntu-12.04
    
    suites:
      - name: default
        run_list:
          - recipe[jdemo::default]
        attributes:


Check these changes into git.

    $ git add .kitchen.yml
    $ git commit -m "removed os from default kitchen.yml"

Now run the kitchen command to create the vm.  Bear in mind that the first time you run this, kitchen (via vagrant) will be going out into the public internet to grab a copy of the base vm.

    $ kitchen create
  
That'll take a while depending on your network creation, but it will create your vm.  We can see the state with the kitchen command as well:

    $ kitchen list
    Instance             Driver   Provisioner  Last Action
    default-ubuntu-1204  Vagrant  ChefSolo     Created

Our default ubuntu 12.04 instance is created.  That's part of what we want though.  We want it converged (even though we didn't TECHNICALLY do anything to it yet other than set up which cookbooks we want to include).

Let's do an empty converge.  This will install the chef client on the VM and then run our base cookbook.

    $ kitchen converge
    -----> Starting Kitchen (v1.2.2.dev)
    -----> Converging <default-ubuntu-1204>...
           Preparing files for transfer
           Resolving cookbook dependencies with Berkshelf 3.1.1...
           Removing non-cookbook files before transfer
    -----> Installing Chef Omnibus (true)
           downloading https://www.getchef.com/chef/install.sh
             to file /tmp/install.sh
           trying wget...
    Downloading Chef  for ubuntu...
    downloading https://www.getchef.com/chef/metadata?v=&prerelease=false&nightlies=false&p=ubuntu&pv=12.04&m=x86_64
      to file /tmp/install.sh.1137/metadata.txt
    trying wget...
    url	https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.12.4-1_amd64.deb
    md5	c45e1d4f7842af1048f788c4452d6cc0
    sha256	595cd1e884efd21f8f5e34bdbe878421a9d5c1c24abd3c669a84e8ed261317a3
    downloaded metadata file looks valid...
    downloading https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.12.4-1_amd64.deb
      to file /tmp/install.sh.1137/chef_11.12.4-1_amd64.deb
    trying wget...
    Comparing checksum with sha256sum...
    Installing Chef
    installing with dpkg...
    Selecting previously unselected package chef.
    (Reading database ... 56035 files and directories currently installed.)
    Unpacking chef (from .../chef_11.12.4-1_amd64.deb) ...
    Setting up chef (11.12.4-1) ...
    Thank you for installing Chef!
           Transferring files to <default-ubuntu-1204>
    [2014-05-12T20:05:56+00:00] INFO: Forking chef instance to converge...

This chunk of noise is the chef client being installed.  Then the chef-client is run.

    Starting Chef Client, version 11.12.4
    [2014-05-12T20:08:29+00:00] INFO: *** Chef 11.12.4 ***
    [2014-05-12T20:08:29+00:00] INFO: Chef-client pid: 1391
    [2014-05-12T20:08:31+00:00] INFO: Setting the run_list to ["recipe[jdemo::default]"] from CLI options
    [2014-05-12T20:08:31+00:00] INFO: Run List is [recipe[jdemo::default]]
    [2014-05-12T20:08:31+00:00] INFO: Run List expands to [jdemo::default]
    [2014-05-12T20:08:31+00:00] INFO: Starting Chef Run for default-ubuntu-1204
    [2014-05-12T20:08:31+00:00] INFO: Running start handlers
    [2014-05-12T20:08:31+00:00] INFO: Start handlers complete.
    Compiling Cookbooks...
    Converging 0 resources
    [2014-05-12T20:08:31+00:00] INFO: Chef Run complete in 0.040130244 seconds
    
    Running handlers:
    [2014-05-12T20:08:31+00:00] INFO: Running report handlers
    Running handlers complete
    
    [2014-05-12T20:08:31+00:00] INFO: Report handlers complete
    Chef Client finished, 0/0 resources updated in 2.146585593 seconds
           Finished converging <default-ubuntu-1204> (0m3.41s).
    -----> Kitchen is finished. (0m3.95s)

And does absolutely nothing.  Let's take a look at the list of vms again and show the last action done against them.

    $ kitchen list
    Instance             Driver   Provisioner  Last Action
    default-ubuntu-1204  Vagrant  ChefSolo     Converged


### Writing your first recipe
 
In the `recipes` subdirectory, you'll find a file named `default.rb`.  We'll be editing that file.  If you take a look in it, there will be only comments.  We're going to tell it to run the defaults from the two cookbooks that we included: `apt` and `tomcat`.  This is called writing a wrapper cookbook.   We add two `include_recipe` lines to our `default.rb` file so that it looks like the following. 

`recipes/default.rb`

    #
    # Cookbook Name:: jdemo
    # Recipe:: default
    #
    # Copyright (C) 2014 
    #
    # 
    #
    
    include_recipe 'apt'
    include_recipe 'tomcat'

Let's see if that does anything more.  

What we expect it to do:
- apt: do an apt update of the packages on ubuntu so that later java install doesn't explode
- tomcat: install first java and then a default tomcat install, start tomcat service

Let's run our converge again.

    $ kitchen converge
    
This should create many screens worth of stuff getting done.  That's fully functional now. 
 
 
Let's do a manual check of the vm to see if our stuff REALLY worked.  To connect to the vagrant instance and magically (key-based auth) login, do the following at the command line in the base directory:

    $ kitchen login

and now you're on the local test host.  Let's confirm that `tomcat` is installed.  I won't explain the commands I suggest.  It's just a call to the package management tool specific to ubuntu.  There are other ways to do this same thing.

    vagrant@default-ubuntu-1204:~$ dpkg -l | grep tomcat6
    ii  libtomcat6-java                  6.0.35-1ubuntu3.4                 Servlet and JSP engine -- core libraries
    ii  tomcat6                          6.0.35-1ubuntu3.4                 Servlet and JSP engine
    ii  tomcat6-admin                    6.0.35-1ubuntu3.4                 Servlet and JSP engine -- admin web applications
    ii  tomcat6-common                   6.0.35-1ubuntu3.4                 Servlet and JSP engine -- common files

This should've installed `java` too.  We can check the same way.

    vagrant@default-ubuntu-1204:~$ dpkg -l | grep openjdk
    ii  openjdk-6-jdk                    6b31-1.13.3-1ubuntu1~0.12.04.2    OpenJDK Development Kit (JDK)
    ii  openjdk-6-jre                    6b31-1.13.3-1ubuntu1~0.12.04.2    OpenJDK Java runtime, using Hotspot JIT
    ii  openjdk-6-jre-headless           6b31-1.13.3-1ubuntu1~0.12.04.2    OpenJDK Java runtime, using Hotspot JIT (headless)
    ii  openjdk-6-jre-lib                6b31-1.13.3-1ubuntu1~0.12.04.2    OpenJDK Java runtime (architecture independent libraries)

We should check if tomcat is running as well.  It should show up in our process list as well as having a port bound in state LISTEN.
 
    vagrant@default-ubuntu-1204:~$ ps aux | grep tomcat | grep -v grep
    tomcat6   9696  0.2 17.5 1034396 65420 ?       Sl   20:49   0:15 /usr/lib/jvm/java-6-openjdk-amd64/bin/java -Djava.util.logging.config.file=/var/lib/tomcat6/conf/logging.properties -Xmx128M -Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.endorsed.dirs=/usr/share/tomcat6/lib/endorsed -classpath /usr/share/tomcat6/bin/bootstrap.jar -Dcatalina.base=/var/lib/tomcat6 -Dcatalina.home=/usr/share/tomcat6 -Djava.io.tmpdir=/tmp/tomcat6-tmp org.apache.catalina.startup.Bootstrap start
    
    vagrant@default-ubuntu-1204:~$ netstat -na | grep 8080 | grep LISTEN
    tcp6       0      0 :::8080                 :::*                    LISTEN

We also know that the java connector listens on 8009.  

    vagrant@default-ubuntu-1204:~$ netstat -na | grep 8009 | grep LISTEN
    tcp6       0      0 :::8009                 :::*                    LISTEN

 
All of those things that we just did there to manually test our work?  We should formalize them using test kitchen with bats or serverspec or something.  We'll do that some other time though. 
 
Last step for now -- let's check it into git

    $ git add recipes/default.rb
    $ git commit -m "added the default recipe wrapper"

That's it for now.

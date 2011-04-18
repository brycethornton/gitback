Gitback
====

Do you have backups of your production web/mail/db configs? crontabs?

How fast could you configure a production machine if everything was lost?

Gitback allows you to version arbitrary files and/or directories in a git
repository.  You just need to include the gem and write a brief ruby script
that indicates the files/directories you'd like to backup.  Then, run the
script via cron.  Gitback will take care of a adding/commiting/pushing whenever
your files are modified.


## Requirements ###############################################################

* git (http://git-scm.com) tested with 1.7.4
* grit (http://github.com/mojombo/grit) tested with 2.4.1


## Install ####################################################################

    $ gem install gitback

## Usage ######################################################################

Here's a basic example of a script using gitback:

    require 'rubygems'
    require 'gitback'

    Gitback::Repository.new '/var/config-backup/' do |repo|
      repo.backup '/opt/nginx/conf/nginx.conf'
      repo.backup '/etc/mysql/'
      repo.backup '/etc/memcached.conf'
      repo.backup '/etc/ssh/sshd_config'
      repo.backup '/var/spool/cron/crontabs/'
    end

This will check these files for additions/changes.  If a file has been added or
changed, gitback will commit it.

For example, the nginx config file would be saved to the following location:

    /var/config-backup/opt/nginx/conf/nginx.conf

Notice that '/etc/mysql' is a directory.  Gitback accepts directories and will
copy everything within that directory into the git repository.


### Namespaces

Namespaces are also supported.  If you'd like to use the same repository for
multiple servers you can specify a namespace like this:

    Gitback::Repository.new '/var/config-backup/' do |repo|
      repo.namespace 'server1.domain.com' do
        repo.backup '/opt/nginx/conf/nginx.conf'
      end
    end

This will save the file to the following location:

    /var/config-backup/server1.domain.com/opt/nginx/conf/nginx.conf


### Remote Git Repositories

Gitback is intended to be used with remote git repositories.  If your git
repository is tracking a remote branch, gitback will push changes to
the remote after each commit.


### Running Via Cron

There's nothing special about a gitback script.  In order for it to backup
your files you'll need to run it via the command line.  I suggest setting up
a cron job to do this for you at regular intervals.

## Copyright ###################################################################

Copyright (c) 2010 Bryce Thornton. See LICENSE for details.

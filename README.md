# Gitty Overview

Gitty is an open-source reduced-functionality Github clone.

On the bright side, you have full access to the source code, so you can add that
feature that you always wished GitHub would have! (Please send a pull request
if you do!) You can also install it behind your firewall for free.


## Dependencies

Gitty relies on git, openssh, and MySQL.

On Fedora:

```bash
sudo yum install -y git openssh-server mysql-devel mysql-server
sudo systemctl enable mysqld.service sshd.service
sudo systemctl start mysqld.service sshd.service
```

On Ubuntu:

```bash
sudo apt-get install -y git libmysqlclient-dev libssl-dev mysql-client mysql-server openssh-server
```

On OSX, go to System Preferences > Sharing, check the Remote Login option.

Gitty uses [markdpwn](https://github.com/pwnall/markdpwn) for source code
highlighting, which has its own dependencies. If you can't get markdpwn's
dependencies installed, set the `markdpwn` config var to `disabled`. (The
section below describes config vars.)


## Installation

Gitty uses the typical Rails 3.x setup sequence.

```bash
bundle install
bundle exec rake db:create db:migrate db:seed
```

Gitty needs a dedicated user for git+ssh. To create the user, run the following
command, replacing web_user with the name of the user that the Rails server runs
under.

```bash
script/git_user/setup git web_user
```

Conventionally, the dedicated user's name is "git". It can be changed by
replacing the first argument in the command above, then changing the
configuration variable git_user by going to

```bash
http://localhost:3000/_/config_vars
```
The admin username and password are config and vars, respectively. You should
probably visit the configuration variables page anyway, to change the admin
login and the address used to send e-mails.

```bash
http://localhost:3000/_/config_vars
```


## Development

Model and controller diagrams might help you wrap your head around the source
code.

```bash
bundle exec rake diagram:all
```

The documentation for the ActiveRecord models assumes knowledge of the
[git object model](http://git-scm.com/book/en/Git-Internals-Git-Objects)

An easy way to seed your development server with git data is to push the gitty
repository into it. Create a user, upload your public SSH key, then create a
`gitty` repository. Run the following commands in the gitty source tree to set
up a `dev` remote pointing to your local server, and push the repo to it.

```bash
git remote add dev git@localhost:your_user_name/gitty.git
git push dev master
```


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version
  unintentionally.
* Send me a pull request. Bonus points for topic branches.


## Credits

Gitty was developed by Victor Costan and a
[team of contributors](https://github.com/pwnall/gitty/contributors).

The favicon is based on the Matrix Code icon from
[The Matrix icon pack](http://iconfactory.com/freeware/preview/mtrx)
by Dave Brasgalla.


## Copyright

Copyright (c) 2010-2012 Victor Costan, released under the MIT license.

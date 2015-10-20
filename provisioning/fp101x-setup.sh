#!/bin/bash
set -e

host_home=/vagrant/fp101x

ruby_version=$(cat $host_home/.ruby-version)

# readline required for proper ruby compilation
# git for install rbenv
# build-essential for g++ for twitter gem)
# redis required
# pg also required
# postgresql-contrib-9.3 required for rake db to run (due to pg_stat_statements)
# libpq-dev required for pg gem
# nodejs is necessary for ExecJS and thus rake (???) to run
sudo apt-get update
sudo apt-get install -y \
    libreadline6 libreadline6-dev \
    git \
    build-essential \
    redis-server \
    postgresql-9.3 postgresql-contrib-9.3 libpq-dev \
    nodejs \
    nginx \
	phantomjs \
	hugs

# if rbenv is not installed, assume this is the first time through
if [ ! `which rbenv` ] ; then
    # install rbenv and ruby-build
    # qv https://github.com/sstephenson/rbenv
    # qv https://github.com/sstephenson/ruby-build#readme
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

    # create a .rubyrc.  This will encapsualate the magic of rbenv
    # quoted heredoc delimiter prevents interpolation
    rubyrc=~/.rubyrc
    cat << 'EOR' > $rubyrc
#!/bin/bash
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
EOR
    # go ahead and source rubyrc
    source $rubyrc

    # add .rubyrc to .bashrc.  The bashrc under linux here will bail out if
    # this is a non-interactive shell (which is what is running over ssh)
    # so stick this bit right near the top
    # NB I don't use $rubyrc here because quoting everyting else inside of sed
    # was painful

    pushd $HOME
    sed -ibak -e '4i\
[[ -s "$HOME/.rubyrc" ]] && source "$HOME/.rubyrc" # always source rbenv, regardless of interactivity' .bashrc

    # finally add a cd to the end of bashrc.  When you vagrant ssh, you almost always want to go
    # to the project directory
    echo "cd $host_home" >> .bashrc

    popd

fi

# see if you have the correct ruby installed
if [ ! `rbenv versions | grep $ruby_version` ] ; then
    rbenv install $ruby_version
    rbenv rehash
fi

# install heroku toolbelt
# if [ ! `which heroku` ] ; then
#     sudo wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
# fi

cd $host_home

# build postgres gem if necessary
# if [ `gem list -i pg`  == 'false' ] ; then
#     ARCHFLAGS="-arch x86_64" gem install pg -- --with-pg-config=`which pg_config`
# fi

# install and run bundler
# gem install bundler
# bundle install
cd $host_home

# initialize postgres
# sudo -u postgres createuser -s $USER || true

# create and seed db
# rake db:setup

# setup hostnames for vagrants
echo '192.168.12.22      my-local' | sudo tee -a /etc/hosts
echo '192.168.44.55 billing-local' | sudo tee -a /etc/hosts
echo '192.168.33.11     api-local api2-local' | sudo tee -a /etc/hosts

# TODO: convert this script to Ansible for server-cm integration

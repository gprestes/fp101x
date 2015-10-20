#!/bin/bash
set -e

host_home=/vagrant/fp101x

sudo apt-get update
sudo apt-get install -y \
    git \
	hugs
	
yes Y | sudo apt-get autoremove	

# if rbenv is not installed, assume this is the first time through
if [ ! `which rbenv` ] ; then
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

    rubyrc=~/.rubyrc
    cat << 'EOR' > $rubyrc
#!/bin/bash
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
EOR
    # go ahead and source rubyrc
    source $rubyrc

    pushd $HOME
    sed -ibak -e '4i\
[[ -s "$HOME/.rubyrc" ]] && source "$HOME/.rubyrc" # always source rbenv, regardless of interactivity' .bashrc

    echo "cd $host_home" >> .bashrc

    popd

fi

cd $host_home

# setup hostnames for vagrants
echo '192.168.12.22      my-local' | sudo tee -a /etc/hosts
echo '192.168.44.55 billing-local' | sudo tee -a /etc/hosts
echo '192.168.33.11     api-local api2-local' | sudo tee -a /etc/hosts

# TODO: convert this script to Ansible for server-cm integration

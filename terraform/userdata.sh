#!/bin/bash
echo "USERDATA APPLIED ON $(date)" > /tmp/userdata
##### CREDS
mkdir -p /root/.aws
echo '
[default]
aws_access_key_id = XXXX
aws_secret_access_key = XXXX
' > /root/.aws/credentials
echo '
[default]
region = us-west-1
' > /root/.aws/config
#

echo "AKIAIIFSDPHBWEBSGPRA:dWg3W7HjqMSPmAxL92wWwfmC0e0Y7RKV7pxmYd8z" > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt update -y
apt install puppet git-core s3fs -y

echo '
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/run/puppet
factpath=$vardir/lib/facter
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post
' > /etc/puppet/puppet.conf

puppet module install puppetlabs-docker_platform --version 2.2.1

s3fs d4a6b2c7a71c7b4dbdda4fbff74b559d /etc/puppet/manifests/ 

# if there is no site.pp it will be created
FILETOCHECK=/etc/puppet/manifests/site.pp
if [[ -f $FILETOCHECK ]] && [[ -s $FILETOCHECK ]]; then
   echo "found file $FILETOCHECK with content: $(cat $FILETOCHECK)"
else
echo '
node default {

  cron { "puppet-apply":
    ensure => present,
    command => "/usr/bin/puppet apply /etc/puppet/manifests/site.pp",
    user => "root",
    minute => "*/1",
  }

  service { "puppet":
    ensure => stopped,
    enable => false,
  }

  package { "docker.io":
    ensure => installed,
    provider => apt,
  }

  package { "python3-pip":
    ensure => installed,
    provider => apt,
  }

  package { "awscli":
    ensure => installed,
    provider => apt,
  }

  service { "docker":
    ensure => running,
    enable => true,
  }

  package { "htop":
    ensure => installed,
  }

  exec {"update_aws_tools":
  command => "pip3 install --upgrade awscli",
  provider => shell,
  require => Package["awscli"],
  }

  exec {"login_to_aws_ecr":
  command => "$(aws ecr get-login --no-include-email --region us-west-1)",
  provider => shell,
  require => Exec["update_aws_tools"],
  }

  docker::run { "quoteapp":
    image   => "577043135686.dkr.ecr.us-west-1.amazonaws.com/quoteapp:latest",
    ports   => [ "8000:8000" ],
    extra_parameters => [ "--restart=always" ],
    volumes          => [ "/root/.aws:/root/.aws:ro" ],
    pull_on_start    => true,
    require => Exec["login_to_aws_ecr"],
  }

}
' > /etc/puppet/manifests/site.pp

fi


puppet apply /etc/puppet/manifests/site.pp





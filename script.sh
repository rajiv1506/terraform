#!/bin/bash
wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
dpkg -i puppet5-release-bionic.deb
apt update -y
apt install puppet -y
rm /etc/puppet/puppet.conf /etc/puppetlabs/puppet/puppet.conf -f
mkdir -p /etc/puppet/
touch /etc/puppet/puppet.conf 
echo "[main]" >> /etc/puppet/puppet.conf
echo "logdir=/var/log/puppet" >> /etc/puppet/puppet.conf
echo "vardir=/var/lib/puppet" >> /etc/puppet/puppet.conf
echo "ssldir=/var/lib/puppet/ssl" >> /etc/puppet/puppet.conf
echo "rundir=/var/run/puppet" >> /etc/puppet/puppet.conf
echo "basemodulepath=./control/modules" >> /etc/puppet/puppet.conf


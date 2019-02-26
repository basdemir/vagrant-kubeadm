#!/bin/bash
# check if a go version is set

clear
if grep "LC_CTYPE" /etc/default/locale > /dev/null
then
    echo "locale exists"
else
    echo ">>> Installing Locale"

    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
    cat /vagrant/vagrantscripts/locales >> /etc/default/locale
    dpkg-reconfigure --frontend noninteractive locales 
    
    echo ">>> Locale set "
fi


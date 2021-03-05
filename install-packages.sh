#!/bin/bash

function install_stack(){    
    db_password=$1
    if [ "`lsb_release -is`" == "Ubuntu" ] || [ "`lsb_release -is`" == "Debian" ]
    then
        sudo apt update
    
        if dpkg-query -l mysql-server apache2; then
            printf "\nApache 2 available already\n"
        else
            sudo apt install apache2
        fi

        # Permission for Apache
        sudo ufw allow in "Apache Full"

        
        if dpkg-query -l mysql-server mysql-server; then
            printf "\n MySQL available already\n"
        else
            db_password=$1
            export DEBIAN_FRONTEND="noninteractive"
            debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_password"  
            debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_password"
            sudo apt install mysql-server  
        fi
        
        if dpkg-query -l php; then
            printf "\n PHP available already\n"
        else
            sudo apt install php libapache2-mod-php php-mysql
        fi


        #Restarting Apache server to reflect changes
        sudo systemctl restart apache2
        sudo systemctl status apache2;
    
    elif [ "`lsb_release -is`" == "CentOS" ] || [ "`lsb_release -is`" == "RedHat" ]
    then
        sudo yum -y install httpd mysql-server mysql-devel php php-mysql php-fpm;
        sudo yum -y install epel-release phpmyadmin rpm-build redhat-rpm-config;
        sudo yum -y install mysql-community-release-el7-5.noarch.rpm proj;
        sudo yum -y install tinyxml libzip mysql-workbench-community;
        sudo chmod 777 -R /var/www/;
        sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
        sudo service mysqld restart;
        sudo service httpd restart;
        sudo chkconfig httpd on;
        sudo chkconfig mysqld on;
    else
        echo "Unsupported Operating System";
    fi
}



function start_servers(){
    sudo systemctl start apache2 mysql
}

function check_status(){
    sudo systemctl status --quiet apache2 mysql
}

function stop_servers(){
    sudo systemctl stop apache2 mysql
}

function install_mysql(){
    db_password=$1
    export DEBIAN_FRONTEND="noninteractive"
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_password"  
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_password"
    sudo apt install mysql-server  

}


function backup(){
    FILE=backup.sql.`date +"%Y%m%d"`
    USER=${DB_USER}

    # (2) in case you run this more than once a day, remove the previous version of the file
    # unalias rm     2> /dev/null
    # rm ${FILE}     2> /dev/null
    # rm ${FILE}.gz  2> /dev/null

    sudo mkdir -p /opt/backups/ 
    mysqldump --opt --user=root --password ${DATABASE} > ${FILE}
    mv ${FILE} /opt/backups/

    gzip $FILE

    echo "${FILE}.gz was created:"
    ls -l ${FILE}.gz
}

option="${1}" 

case ${option} in 
   -i)  echo "Installing lamp stack"
        read -p "Enter mysql root password: " db_root_password
        install_stack "$db_root_password"
      ;; 

   start) echo "Starting servers..."
        start_servers
        echo "started"
      ;;
   status)  echo "Checking status of servers "
        check_status
      ;;

   stop) echo "Stopping servers..."
        stop_servers
        echo "stopped"
      ;;
   *)  
      echo "`basename ${0}`:usage: [-install install lamp stack] | [-status show status] | [-stop stop servers] | [-start start servers]" 
      exit 1 # Command to come out of the program with status 1
      ;; 
esac 
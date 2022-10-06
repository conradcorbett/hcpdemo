#!/bin/bash
set -ex

sudo hostnamectl set-hostname mysqldb

#curl -sSLO https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
#sudo rpm -ivh mysql57-community-release-el7-9.noarch.rpm
#sudo yum install mysql-server

# -*- Mysql installation 
sudo yum install -y "http://repo.mysql.com/mysql80-community-release-el7.rpm"
#sudo yum update -y --quiet
sudo yum install -y sshpass mysql-community-server.x86_64

sudo systemctl enable mysqld
sudo systemctl start mysqld

sudo systemctl stop firewalld
sudo yum install -y python3-devel mysql-devel

password=$(sudo grep -oP 'temporary password(.*): \K(\S+)' /var/log/mysqld.log)
sudo mysqladmin --user=root --password="$password" password aaBB**cc1122

sudo mysql -uroot -paaBB**cc1122 <<EOF
CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'aaBB**cc1122';
GRANT ALL PRIVILEGES ON *.* to root@'%' WITH GRANT OPTION;
CREATE USER 'vaultroot'@'%' IDENTIFIED WITH mysql_native_password BY 'aaBB**cc1122';
GRANT ALL PRIVILEGES ON *.* to vaultroot@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE flaskapp;
USE flaskapp;
CREATE TABLE users(name varchar(20), email varchar(40));
EOF

#GRANT ALL PRIVILEGES ON *.* to root@'%' WITH GRANT OPTION;
#IDENTIFIED BY 'aaBB**cc1122';
#FLUSH PRIVILEGES;

#CREATE USER 'flaskmysqluser'@'%' IDENTIFIED BY 'aaBB**cc1122';
#GRANT ALL PRIVILEGES ON *.* TO 'flaskmysqluser'@'%' WITH GRANT OPTION;
#FLUSH PRIVILEGES;

#ALTER USER 'root'@'10.42.42.110' IDENTIFIED WITH mysql_native_password BY 'aaBB**cc1122'; 
#FLUSH PRIVILEGES;

#select user,host from user;
#sudo mysql -uroot -paaBB**cc1122
#USE flaskapp;
#SELECT * FROM users;
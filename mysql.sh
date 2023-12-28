#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.bkdevops.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
    then
        echo -e "$R ERROR:: please run this script with root access $N"
        exit 1
    else
        echo "you are root user"
fi

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disbling current mysql" 

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql" 

systemctl enable mysqld
VALIDATE $? "Enabling mysql".

systemctl start mysqld
VALIDATE $? "Starting mysql"

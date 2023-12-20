#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.bkdevops.online

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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx" 

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting nginx" 

rm -rf /usr/share/nginx/html/*

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

cd /usr/share/nginx/html

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "Unzipping web"

cp /home/centos/roboshop-shell/roboshop.service /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "Reverse proxy configuration"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "web Daemon-reload"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restart nginx"

#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 ..... $R FAILED $N"
    exit 1
    else
    echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
    then
    echo -e "$R ERROR:: please run this script with root access $N"
    exit 1
    else
    echo "you are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disbling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:18" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs: 18" 

useradd roboshop
VALIDATE $? "Creating roboshop user" 

mkdir /app
VALIDATE $? "Making directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue application"

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unziping catalogue application " 

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies " 

# Here use abosulte path,bcoz catalogue.service exists there only
cp home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload
VALIDATE "Catalogue Daemon-reload" 

systemctl enable catalogue
VALIDATE $? "Enabling catalogue"

systemctl start catalogue
VALIDATE $? "Starting catalogue" 

cp home/centos/roboshop-shell/mango.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo file"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing client server" 

mongo --host mongodb.bkdevops.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue data into MongoDB"

































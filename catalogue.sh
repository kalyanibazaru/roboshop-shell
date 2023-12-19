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

dnf module disable nodejs -y
VALIDATE $? "Disbling current nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y
VALIDATE $? "Enabling nodejs:18" &>> $LOGFILE

dnf install nodejs -y
VALIDATE $? "Installing nodejs: 18" &>> $LOGFILE

useradd roboshop
VALIDATE $? "Creating roboshop user" &>> $LOGFILE

mkdir /app
VALIDATE $? "Making directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading catalogue application" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip
VALIDATE $? "Unziping catalogue application " &>> $LOGFILE

npm install 
VALIDATE $? "Installing dependencies " &>> $LOGFILE

# Here use abosulte path,bcoz catalogue.service exists there only
cp home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload
VALIDATE "Catalogue Daemon-reload" &>> $LOGFILE

systemctl enable catalogue
VALIDATE $? "Enabling catalogue" &>> $LOGFILE

systemctl start catalogue
VALIDATE $? "Starting catalogue" &>> $LOGFILE

cp home/centos/roboshop-shell/mango.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo file"

dnf install mongodb-org-shell -y
VALIDATE $? "Installing client server" &>> $LOGFILE

mongo --host mongodb.bkdevops.online </app/schema/catalogue.js

































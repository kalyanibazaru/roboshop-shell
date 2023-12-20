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
    echo -e "$2 .. $R FAILED $N"
    exit 1
    else
    echo -e "$2 .. $G SUCCESS $N"
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

id roboshop #if roboshop user does not exist
if [ $? -ne 0 ]
    then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
    else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi 

mkdir -p /app
VALIDATE $? "Creating app directory" 

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping user application " 

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies" 

# Here use abosulte path,bcoz catalogue.service exists there only
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE "user Daemon-reload" 

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client" 

mongo --host $MONGODB_HOST </app/schema/user.js
VALIDATE $? "Loading user data into MongoDB"

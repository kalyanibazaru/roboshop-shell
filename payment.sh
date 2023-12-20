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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing python application"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment application"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping payment application" 

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying pyment service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "pyment Daemon-reload" 

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling pyment"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting pyment" 
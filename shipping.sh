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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Java"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping application"

cd /app 

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping application" 

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing java application" 

mv target/shipping-1.0.jar shipping.jar

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "shipping Daemon-reload" 

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Instaling shipping"

mysql -h mysql.bkdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping"



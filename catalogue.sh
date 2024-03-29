#!bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.swamydevops.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... $R Failed $N"
        exit 1
    else   
        echo -e "$2... $G Success $N"
    fi # fi means reverse of if indicating condition end
}

if [ $ID -ne 0 ]
then
    echo "$R Error:: Please run this script with root access $N"
    exit 1 # you can give greater than 0
else
    echo "You are root user"
fi # fi means reverse of if indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling Nodejs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs:18" 

id roboshop # if roboshop user does not exist then it is failure
    if [ $? -ne 0 ]
    then
        useradd roboshop &>> $LOGFILE
        VALIDATE $? "roboshop user Cretion" 
    else
        echo -e "roboshop user already exist $Y SKIPPING $N"
    fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue application" 

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue application" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalogue daemon reload" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue" 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting Catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongodb repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into MongoDB"
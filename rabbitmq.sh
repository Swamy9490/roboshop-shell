#!/bin/bash

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
    if [ $1 -ne 0]
    then
        echo -e "$2... $R Failed $N"
        exit 1 
    else
        echo -e "$2... $G Success $N"
    fi # fi means reverse of if indicating condition end
}

if [ $ID -ne 0 ]
then
    echo -e "$R Error:: Please run this script with root access $N"
    exit 1 # you can give greater than 0
else
    echo -e "you are root user"
fi # fi means of reverse of if indicating condition end

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash

VALIDATE $? "Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash

VALIDATE $? "Downloading RabbitMQ server"

dnf install rabbitmq-server -y 

VALIDATE $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server

VALIDATE $? "Enable rabbitmq server"

systemctl start rabbitmq-server 

VALIDATE $? "Start rabbitmq server"

rabbitmqctl add_user roboshop roboshop123

VALIDATE $? "Creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

VALIDATE $? "setting permissions"
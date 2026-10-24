#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if  [ $user_id -ne 0 ]; then
   echo "please run this script with sudo access"
   exit 1
 fi

 mkdir -p $logs_folder

 timestamp(){
    date +"%F %T"
 }

 echo "scipt started executing at $(date +"%F %T")"  &>> $logs_file

validate(){
   if [ $1 -ne 0 ]; then 

   echo -e "$(timestamp)[ERROR]......${R}FAILED${N}" | tee -a $logs_file
   exit 1

   else 
   echo -e "$(timestamp)[INFO].... ${G}SUCCESS${N}" | tee -a $logs_file

   fi
}

echo "$(timestamp)[INFO] === Scripted started and execution" | tee -a $logs_file

cp  /etc/yum.repos.d/rabbitmq.repo  &>> $logs_file

dnf install erlang rabbitmq-server -y   &>> $logs_file
validate $? "Install Erlang and RabbitMQ:"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Start & enable the RabbitMQ service:"


rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "create RabbitMQ user"


echo "$(timestamp)[INFO] === Scripted Completed in $SECONDS seconds"
echo "$(timestamp)[INFO] === Scripted Completed and execution" | tee -a $logs_file
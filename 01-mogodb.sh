#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"

if  [ $user_id -ne 0 ]; then
   echo "please run this script with sudo access"
   exit 1
 fi

 mkdir -p $logs_folder

 echo "scipt started executing at $(date +"%F %T")"  &>> $logs_file

validate(){
   if [ $1 -ne 0 ]; then 

   echo " ${2}......failed" | tee -a $logs_file
   exit 1

   else 
   echo " ${1}.... Sucess " | tee -a $logs_file

   fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

dnf install mongodb-org -y
validate $? "install mongodb"

systemctl enable mongod
systemctl start mongod
validate $? "Start & enable the MongoDB service"


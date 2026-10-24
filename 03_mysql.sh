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

dnf module enable mysql:8.4 -y  &>> $logs_file
dnf install mysql-server -y  &>> $logs_file
validate $? "Sql sucessfully installed"

systemctl enable mysqld  &>> $logs_file
systemctl start mysqld  &>> $logs_file
validate $? "Start & enable the MySQL service:"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logs_file
validate $? "Set the root password"

echo "$(timestamp)[INFO] === Scripted Completed in $SECONDS seconds"
echo "$(timestamp)[INFO] === Scripted Completed and execution" | tee -a $logs_file
#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="daw92ss.store"
scripts_dir=$(dirname  "$(realpath "$0")")
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

dnf module disable nodejs -y  &>> $logs_file
dnf module enable nodejs:24 -y  &>> $logs_file
dnf install nodejs -y  &>> $logs_file
validate $? "Installing the nodejs 24"


if [ $? ne- 0 ]; then

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Applicatoin is going to run non user "

else 

echo -e "$(timestamp)[INFO] catlogs already exit .....${Y}Skipping${N}"

fi

mkdir -p /app
validate $? "app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validate $? "Download the catlogue"

cd /app
unzip /tmp/catalogue.zip &>> $logs_file
validate $? "unzip the catlogue file"

npm install &>> $logs_file
validate $? "install dependencies"



 sed -i "s/DOMIN_NAME/$domain_name" " $scripts_dir/catalogue.service

  cp "$scripts_dir/catalogue.repo"  /etc/systemd/system/catalogue.service
  #validate $? "adding vim files into catalogues"





echo "$(timestamp)[INFO] === Scripted Completed in $SECONDS seconds"
echo "$(timestamp)[INFO] === Scripted Completed and execution" | tee -a $logs_file
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


if id roboshop &>/dev/null; then
    echo -e "$(timestamp)[INFO] roboshop user already exists.....${Y}Skipping${N}"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Creating roboshop user"
fi

rm -rf /app
validate $? "removeing old application directory"

mkdir -p /app
validate $? "app directory"

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip &>> $logs_file
validate $? "Download the user"

cd /app
unzip /tmp/user.zip &>> $logs_file
validate $? "unzip the user file"

npm install &>> $logs_file
validate $? "install dependencies"



cp "$scripts_dir/user.service" /etc/systemd/system/user.service

sed -i "s/DOMAIN_NAME/$domain_name/g" /etc/systemd/system/user.service

  validate $? "adding vim files into user"


systemctl daemon-reload  &>> $logs_file
systemctl enable user  &>> $logs_file
systemctl start user  &>> $logs_file

validate $? "Load and start user service"


systemctl restart user
validate $? "restarting user"

echo "$(timestamp)[INFO] === Scripted Completed in $SECONDS seconds"
echo "$(timestamp)[INFO] === Scripted Completed and execution" | tee -a $logs_file



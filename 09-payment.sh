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


echo "$(timestamp)[INFO] === Scripted start and execution" | tee -a $logs_file


dnf install python3.14 python3.14-pip -y  &>> $logs_file
python3.14 --version &>> $logs_file
validate $? "Install python"


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

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip &>> $logs_file
validate $? "Download the payment"

cd /app
python3.14 -m venv /app/.venv   &>> $logs_file
validate $? "Creating virtual environment"

echo "$(timestamp)[INFO] === checking at before install dependencies $SECONDS seconds"

/app/.venv/bin/pip install -r requirements.txt   &>> $logs_file
validate $? "Install dependencies" 


cp "$scripts_dir/payment.service" /etc/systemd/system/payment.service
sed -i "s/DOMAIN_NAME/$domain_name/g" /etc/systemd/system/payment.service
validate $? "adding vim files into payment"

echo "$(timestamp)[INFO] === checking in $SECONDS seconds"

systemctl daemon-reload  &>> $logs_file
systemctl enable payment  &>> $logs_file
systemctl restart payment  &>> $logs_file
validate $? "restarting payment"

echo "$(timestamp)[INFO] === Scripted Completed in $SECONDS seconds"
echo "$(timestamp)[INFO] === Scripted Completed and execution" | tee -a $logs_file



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

dnf module enable maven:3.9 -y  &>> $logs_file
dnf install maven java-25-openjdk-devel -y  &>> $logs_file
validate $? "install maven and java "

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "seting as default java version 24"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME 

validate $? "seting java maven version"

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

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $logs_file
validate $? "Download the shipping"

cd /app
unzip /tmp/shipping.zip &>> $logs_file
validate $? "unzip the shipping file"

mvn clean package &>> $logs_file
validate $? "install dependencies"

mv target/shipping.jar shipping.jar
validate $? "maven shipping jar file"



cp "$scripts_dir/shipping.service" /etc/systemd/system/shipping.service

sed -i "s/DOMAIN_NAME/$domain_name/g" /etc/systemd/system/shipping.service
validate $? "adding vim files into shipping"

dnf install mysql -y &>> $logs_file
validate $? "install my sql"


count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;"  2>> $logs_file)

if [ -z "$count" ] || [ "$count"  -eq 0 ]; then 

mysql -h "mysql.${domain_name}" -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "Loading shipping data"

else 

echo -e  echo -e "$(timestamp)[INFO] master data already loaded.....${Y}Skipping${N}"

fi 

mysql -h "mysql.${domain_name}" -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "Creating app user "


systemctl daemon-reload  &>> $logs_file
systemctl enable shipping  &>> $logs_file
systemctl restart shipping  &>> $logs_file
validate $? "restarting shipping"

echo "$(timestamp)[INFO] === Scripted Completed in $SECONDS seconds"
echo "$(timestamp)[INFO] === Scripted Completed and execution" | tee -a $logs_file



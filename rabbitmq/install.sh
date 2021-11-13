LOG=/tmp/roboshop.log
rm -f $LOG

Status_Check() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
    echo -e "\e[33m Refer Log file : $LOG for more information\e[0m"
    exit 2
  fi
}

Print() {
  echo -e "\n\t\t\e[36m----------------- $1 ----------------------\e[0m\n" >>$LOG
  echo -n -e "$1 \t- "
}


Print "Install ErLang\t"
  yum list installed | grep erlang &>>$LOG
  if [ $? -eq 0 ]; then
    echo "Package Already installed" &>>$LOG
  else
    yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>>$LOG
  fi
Status_Check $?

Print "Setup RabbitMQ Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG
Status_Check $?

Print "Install RabbitMQ"
yum install rabbitmq-server -y &>>$LOG
Status_Check $?

Print "Start RabbitMQ\t"
systemctl enable rabbitmq-server  &>>$LOG  && systemctl start rabbitmq-server &>>$LOG
Status_Check $?

Print "Create App user"
rabbitmqctl list_users | grep roboshop &>>$LOG
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>>$LOG
fi
rabbitmqctl set_user_tags roboshop administrator &>>$LOG && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG
Status_Check $?

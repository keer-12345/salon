#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n ~~~~~~MY SALON~~~~~~\n"
echo -e "\n Welcome to My salon, how can I help you?\n"

SERVICES=$($PSQL "SELECT service_id, name FROM services;")
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
 echo "$SERVICE_ID) $NAME Service"
done

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read -p "Enter the service ID you would like: " SERVICE_ID_SELECTED
  HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $HAVE_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. Please choose a service from the following list:"
  fi

  read -p "What's your phone number? " CUSTOMER_PHONE
  HAVE_CUST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $HAVE_CUST ]]
  then
    read -p "I don't have a record for that phone number, what's your name? " CUSTOMER_NAME
    INSERTED=$($PSQL "INSERT INTO customers (name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE') RETURNING customer_id")
    CUSTOMER_ID=$(echo $INSERTED | sed 's/ //g')
  else
    CUSTOMER_ID=$(echo $HAVE_CUST | awk '{print $1}')
    CUSTOMER_NAME=$(echo $HAVE_CUST | awk '{print $2}')
  fi

  read -p "What time would you like your $(echo $HAVE_SERVICE | awk '{print $2}') service, $CUSTOMER_NAME? " SERVICE_TIME

  INSERTED_APPT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') RETURNING service_id")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$(echo $INSERTED_APPT | awk '{print $1}')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | awk '{print $1}') at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

MAIN_MENU



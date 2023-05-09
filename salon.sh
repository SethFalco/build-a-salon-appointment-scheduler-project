#!/bin/bash
PSQL='psql -Atq -U freecodecamp -d salon -c'
SERVICES=$($PSQL 'SELECT * FROM services;' | awk -F '|' '{ print $1") " $2 }')

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?"

SELECT_SERVICE() {
  echo -e "\n$SERVICES"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    SELECT_SERVICE
    return
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED";)

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    SELECT_SERVICE
  fi
}

SELECT_SERVICE

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
if [[ $CUSTOMER ]]
then
  IFS='|' read CUSTOMER_ID CUSTOMER_NAME <<< $CUSTOMER
else
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  echo $($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');") >> /dev/null
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');") >> /dev/null
echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."

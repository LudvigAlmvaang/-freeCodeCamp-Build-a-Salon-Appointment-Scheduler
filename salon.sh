#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ Hair Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Select a service!"
  echo -e "\n1) Hair cut\n2) Hair color\n3) Hair extensions\n4) Perms and Relaxers\n5) Exit"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-4]) SALON_APPOINTMENT ;;
    5) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

FIND_CUSTOMER() {
  echo "Please enter your phone number."
  read CUSTOMER_PHONE
  GET_CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $GET_CUSTOMER ]]
  then
    echo "Phone number was not found."
    echo -e "Enter your name!"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    echo "New customer inserted."
    # Get new customer
    GET_CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    echo -e "Customer found."
  fi
  # Get customer name
  GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$GET_CUSTOMER'")
}

SELECT_TIME() {
  echo "Enter a time for the appointment!"
  read SERVICE_TIME
}

FINILIZE_APPOINTMENT() {
  # Get the service name
  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # Format the service and customer name
  SERVICE_NAME_FORMATED=$(echo $GET_SERVICE_NAME | sed 's/^ *//; s/ *$//')
  CUSTOMER_NAME_FORMATED=$(echo $GET_CUSTOMER_NAME | sed 's/^ *//; s/ *$//')
  # Insert the appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($GET_CUSTOMER, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  # Print the confirmation of appointment
  echo "I have put you down for a $SERVICE_NAME_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATED."
}

EXIT() {
  echo -e "\nBye!\n"
}

SALON_APPOINTMENT() {
  FIND_CUSTOMER
  SELECT_TIME
  FINILIZE_APPOINTMENT
  EXIT
}

MAIN_MENU

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Script that creates a random number between 1 and 1000 for users to guess.

# functions to describe script outline.
# asks for users name and generates a random number and tracks number of guesses.
INTRODUCTION() {
  SECRET_NUMBER=$(((RANDOM % 1000) + 1))
  NUMBER_OF_GUESSES=0

  echo -e "\nEnter your username:"
  read USERNAME
}

# gets the user from database alongside game relevant info.
# if user not found, set as new user in database
GET_USER() {
  IFS="|" read NAME GAMES_PLAYED BEST_GAME <<< $($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME';")
  if [[ -z $NAME ]]
    then
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
      ADD_USER_RESULT=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES('$USERNAME', 1, 0);")
      GAMES_PLAYED=1
      BEST_GAME=0
    else
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      GAMES_PLAYED=$(($GAMES_PLAYED + 1))
  fi
}

# tell the user what to do and account for guess number 1
PROMPT_USER() {
  echo -e "\nGuess the secret number between 1 and 1000:"
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
}

# track users number guess
GET_USER_GUESS() {
  read USER_GUESS
}

# checks users input and gives output in response to input
CHECK_USER_GUESS() {
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
      then
        echo -e "\nThat is not an integer, guess again:"
        GET_USER_GUESS
        CHECK_USER_GUESS
    elif [[ $SECRET_NUMBER -gt $USER_GUESS ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
        GET_USER_GUESS
        CHECK_USER_GUESS
    elif [[ $SECRET_NUMBER -lt $USER_GUESS ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
        GET_USER_GUESS
        CHECK_USER_GUESS
    else
        UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED;")
        if [[ $BEST_GAME -eq 0 ]]
            then
              UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
          elif [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
            then
              UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
        fi
        echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER, Nice job!"
  fi
}

# script outline as main function
MAIN() {
  INTRODUCTION
  GET_USER
  PROMPT_USER
  GET_USER_GUESS
  CHECK_USER_GUESS
}

# call main
MAIN

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo $SECRET_NUMBER
NUMBER_OF_GUESS=0

echo "Enter your username:"
read PLAYER_NAME

USERNAME=$($PSQL "SELECT username FROM users WHERE username='$PLAYER_NAME'")

USER_INFO=$($PSQL "SELECT MIN(score), COUNT(user_id) FROM games JOIN users USING(user_id) WHERE username='$USERNAME'")


if [[ $USERNAME ]]
then
  echo "$USER_INFO" | while IFS="|" read BEST_GAME GAMES_PLAYED
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
else
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$PLAYER_NAME')")

  if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nWelcome, $PLAYER_NAME! It looks like this is your first time here."
  fi
fi

START_GAME() {
  echo -e "\nGuess the secret number between 1 and 1000:"

  until [[ $GUESS_NUMBER == $SECRET_NUMBER ]]
  do
    read GUESS_NUMBER

    if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      let "NUMBER_OF_GUESS+=1"
    else

      if [[ $GUESS_NUMBER < $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        let "NUMBER_OF_GUESS+=1"
      elif [[ $GUESS_NUMBER > $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        let "NUMBER_OF_GUESS+=1"
      else
        let "NUMBER_OF_GUESS+=1"
        echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"
      fi
    fi
    
  done

  
}
START_GAME

# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$PLAYER_NAME'")
# insert into games
INSERT_SCORE=$($PSQL "INSERT INTO games(score, user_id) VALUES($NUMBER_OF_GUESS, $USER_ID)")



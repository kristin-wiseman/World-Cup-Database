#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams;")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPP WGOALS OPGOALS
do
if [[ $WINNER != "winner" ]]; then
  # get winner's and opponent's IDs
  W_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
  O_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP';")

  # situations:
  # both winner and opponent need to be added
  if [[ -z $W_ID && -z $O_ID ]]; then
    # insert both
    echo $($PSQL "INSERT INTO teams(name) VALUES('$WINNER'), ('$OPP');")
    # get both newly created IDs
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP';")
  
  # only winner needs to be added
  elif [[ -z $W_ID ]]; then
    # insert winner
    echo $($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
    # get winner's newly created ID
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
  
  # only opponent needs to be added
  elif [[ -z $O_ID ]]; then
    # insert opponent
    echo $($PSQL "INSERT INTO teams(name) VALUES('$OPP');")
    # get opponent's newly created ID
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP';")
  fi
  
  echo $($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WGOALS, $OPGOALS, $W_ID, $O_ID);")
fi
done 
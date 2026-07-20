#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Clear existing data
echo $($PSQL "TRUNCATE TABLE games, teams")

# Loop through CSV (skipping header)
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Skip the header line
  if [[ $YEAR != "year" ]]
  then
    # 1. Insert teams if they don't exist
    for TEAM in "$WINNER" "$OPPONENT"
    do
      $PSQL "INSERT INTO teams(name) VALUES('$TEAM') ON CONFLICT(name) DO NOTHING"
    done

    # 2. Get the IDs (using -t to get only the value)
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # 3. Insert the game row
    # Ensure all variables are present
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS)"
  fi
done
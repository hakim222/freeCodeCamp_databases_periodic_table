#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if echo "$1" | sed -E 's/^[0-9]+(\.[0-9]+)?$//g' | grep -q '^$'; 
    then
      RESULT1=$($PSQL "select atomic_number, symbol, name  from elements where atomic_number=$1")
    else
      RESULT1=$($PSQL "select atomic_number, symbol, name  from elements where symbol='$1' or name='$1'")
  fi
  IFS='|' read ATOMIC_NUMBER SYMBOL NAME <<< "$RESULT1"
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo I could not find that element in the database.
  else
    RESULT2=$($PSQL "select b.type, a.atomic_mass, a.melting_point_celsius, a.boiling_point_celsius from properties a left join types b on b.type_id=a.type_id where a.atomic_number=$ATOMIC_NUMBER")
    IFS='|' read TYPE ATOMIC_MASS MELTING BOILING <<< "$RESULT2"
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
fi
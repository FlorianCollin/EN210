#!/bin/bash
while read -r line
do
  echo -en "$line" > $2
done < "$1"

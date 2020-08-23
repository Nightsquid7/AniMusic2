#!/usr/local/bin/bash
# get next season that should be run as argument for main.go, 
# run scraper with it 

./getNextSeasonString.sh > nextSeasonCommand.txt

./nextSeasonCommand.txt

exit 0
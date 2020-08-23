#!/usr/local/bin/bash


declare -A seasons

# this script must be run in /Users/stevenberkowitz/Development/Nightsquid Personal Projects/AniMusic/AniMusic2/scraper/cmd/animusic
for season in $(ls .cache/*.json) ; 
  do 
    currentSeason=$(echo $season | sed 's/\.cache\///' | cut -d "-" -f1)
    if [[ -z ${seasons[$currentSeason]} ]] 
    then 
        # assign year to seasons[currentSeason]
        seasons[$currentSeason]=$(echo $season | sed 's/\.cache\///' | cut -d '-' -f2 | cut -d '.' -f1)
        #echo "earliest $currentSeason in database is " ${seasons[$currentSeason]} 
    fi
done

declare -a nextSeason
declare -a nextYear

# store season with oldest 
for month in ${!seasons[@]} ;
  do

    if [[ -z $greatestYear ]] # initialize variables the first iteration of the loop
      then
        greatestYear=${seasons[$month]}
        nextSeason=$month
        oldestYear=greatestYear
    fi

    if [[ ${seasons[$month]} -gt $greatestYear ]]
      then
        greatestYear=${seasons[$month]}
        nextSeason=$month 
        oldestYear=${seasons[$month]}
    fi
done
nextYear=$(( $oldestYear - 1 ))


#echo the next season to run the scraper is $nextSeason $nextYear


echo go run main.go -s=\"${nextSeason} ${nextYear}\" -cache=false  -ss='7233c710ced44743882ebac79670e22c'  -sid='b37b31d992a944278709986f10ec59d4' -firebaseCredPath='../../../animusic2-70683-firebase-adminsdk-44dws-cc5407e931.json' -sb=animusic2-70683  -sn='animusic2-70683'

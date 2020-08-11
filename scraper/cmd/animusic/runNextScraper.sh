#!/usr/local/bin/bash


declare -A seasons

for season in $(ls .cache/*.json) ; 
  do 
    currentSeason=$(echo $season | sed 's/\.cache\///' | cut -d "-" -f1)
    
    if [[ -z ${seasons[$currentSeason]} ]] 
    then 
        # assign year to seasons[currentSeason]
        seasons[$currentSeason]=$(echo $season | sed 's/\.cache\///' | cut -d '-' -f2 | cut -d '.' -f1)
        echo "stored " ${seasons[$currentSeason]} "in season $currentSeason"
    fi

    
done

echo ${!seasons[@]} ${seasons[@]}

# https://stackoverflow.com/questions/6723426/looping-over-arrays-printing-both-index-and-value/6723516
for year in ${seasons[@]} ;
  do
    if [[ -z $greatestYear ]] 
      then
        greatestYear=$year
        echo "setting greatestYear to " $greatestYear
    fi

    if [[ $year -gt $greatestYear ]]
      then
        greatestYear=$year
        echo "setting greatestYear to " $greatestYear ${!seasons[@]}
    fi
done


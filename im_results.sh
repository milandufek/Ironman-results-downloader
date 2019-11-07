#!/bin/bash

# e.g.
# BASE_LINK="https://www.ironman.com/triathlon/events/emea/ironman-70.3/zell-am-see-kaprun/results.aspx"
# BASE_LINK="https://eu.ironman.com/triathlon/events/emea/ironman/austria/results.aspx"

BASE_LINK="https://eu.ironman.com/triathlon/events/emea/ironman/austria/results.aspx"
START_DIR=$(pwd)
RESULTS="$START_DIR/results.csv"
TMP_DIR=./tmp

function download_failed() {
    echo "Download failed $1"
    exit $?
}

if [ ! -d $TMP_DIR ]; then
    mkdir -p $TMP_DIR
fi

cd $TMP_DIR
RES_FILE=$(echo $BASE_LINK | awk -F '/' '{print $NF}') && rm -f ${RES_FILE}*

echo "Downloader started"
wget -q $BASE_LINK || download_failed $?
PAGES=$(grep -Eo "results.aspx\?p=[0-9]{2,3}" $RES_FILE | tail -1 | awk -F '=' '{print $NF}')

STATUS_MSG="Downloading"
PROGRESS_CHAR="."
BAR=$PROGRESS_CHAR
for PAGE in $(seq 2 $PAGES); do
    [ $(($PAGE % 10)) -eq 0 ] && BAR="${BAR}${PROGRESS_CHAR}"
    [ $PAGE -eq $PAGES ] && STATUS_MSG="Completed"
    printf "%-12s %-40s (%d/%d)\r" "$STATUS_MSG" $BAR $PAGE $PAGES
    wget -q ${BASE_LINK}?p=$PAGE || download_failed $?
done && echo -e "\n"

echo "Surname;Name;Country;DivRank;GenderRank;OverallRank;Swim;Bike;Run;Finish" > $RESULTS
grep ";bidid=" ${RES_FILE}* \
   | awk '{print $3,$4,$5,$6.$7,$8,$9,$10,$11,$12}' \
   | sed -e 's/class="athlete">//' \
         -e 's/<\/a><\/span>//' \
         -e 's/<td>/;/g' \
         -e 's/<\/td>//g' \
   | tr -d ' ' >>$RESULTS

rm -f ${RES_FILE}*
cd $START_DIR
exit 0

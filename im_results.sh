#/usr/bin/bash

# e.g. https://www.ironman.com/triathlon/events/emea/ironman-70.3/zell-am-see-kaprun/results.aspx
BASE_LINK="https://www.ironman.com/triathlon/events/emea/ironman-70.3/zell-am-see-kaprun/results.aspx"
RESULTS="results.csv"

RES_FILE=$(echo $BASE_LINK | awk -F '/' '{print $NF}') && rm -f ${RES_FILE}*

wget $BASE_LINK || exit $?
PAGES=$(grep -Eo "results.aspx\?p=[0-9]{2,3}" $RES_FILE | tail -1 | awk -F '=' '{print $NF}')

for i in $(seq 2 $PAGES); do
    wget -q ${BASE_LINK}?p=$i
done

echo "Name;Country;DivRank;GenderRank;OverallRank;Swim;Bike;Run;Finish" > $RESULTS
grep "rd=20190901&amp;race=salzburg70.3&amp;bidid=" ${RES_FILE}* \
   | awk '{print $3,$4,$5,$6.$7,$8,$9,$10,$11,$12}' \
   | sed -e 's/class="athlete">//' -e 's/<\/a><\/span>//' -e 's/<td>/;/g' -e 's/<\/td>//g' \
   | tr -d ' ' >>$RESULTS

rm -f ${RES_FILE}*


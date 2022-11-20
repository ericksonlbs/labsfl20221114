#!/bin/sh

PATHLOCAL=$PWD
LOGFILE="$PWD/test/log.txt"

if [ ! -d "$PWD/test/" ]; then
        mkdir "$PWD/test/"
fi

echo "execution Csv1b"  >> "$LOGFILE"
#Execute Csv - version 1b Defects4J
bash ./sfl.sh projects/Csv1b "$REPEAT" >> "$LOGFILE"
cd "$PATHLOCAL" || exit

echo "execution Jsoup1b"  >> "$LOGFILE"
#Execute Jsoup - version 1b Defects4J
bash ./sfl.sh projects/Jsoup1b "$REPEAT" >> "$LOGFILE"
cd "$PATHLOCAL" || exit

echo "execution Time1b"  >> "$LOGFILE"
#Execute Time - version 1b Defects4J
bash ./sfl.sh projects/Time1b "$REPEAT" >> "$LOGFILE"
cd "$PATHLOCAL" || exit

echo "execution Gson1b"  >> "$LOGFILE"
#Execute Gson - version 1b Defects4J
bash ./sfl.sh projects/Gson1b/gson "$REPEAT" >> "$LOGFILE"
cd "$PATHLOCAL" || exit

echo "execution Lang1b"  >> "$LOGFILE"
#Execute Lang - version 1b Defects4J
bash ./sfl.sh projects/Lang1b "$REPEAT" >> "$LOGFILE"
cd "$PATHLOCAL" || exit
    
echo "execution Collections25b"  >> "$LOGFILE"
#Execute Collections - version 25b Defects4J
bash ./sfl.sh projects/Collections25b "$REPEAT" >> "$LOGFILE"
cd "$PATHLOCAL" || exit

cd "$PATHLOCAL/test" || exit

timeNow=$(date +%Y-%m-%d_%H-%M-%S)

zip -r "$PATHLOCAL/test/log-$timeNow.zip" "$PATHLOCAL/test/" -x "*.zip"

rm ./*.csv ./*.xml ./*.txt
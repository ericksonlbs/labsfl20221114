#!/bin/sh

PATHLOCAL=$PWD
LOGFILE="$PWD/test/log.txt"

if [ ! -d "$PWD/test/" ]; then
        mkdir "$PWD/test/"
fi

for proj in   'JacksonDatabind80b' 'Gson18b' 'Math104b' 'JacksonXML2b' 'Compress47b' 'Codec18b' 'Csv1b' 'Jsoup93b' 'Time1b' 'Lang1b' 'Collections25b'
do
    echo "execution $proj"  >> "$LOGFILE"
    cd "$PATHLOCAL" || exit

    if [ $proj = 'Gson18b' ]; then
        bash ./sfl.sh "projects/$proj/gson" "$REPEAT" $proj "$LOGFILE"  >> "$LOGFILE"    
    else
        bash ./sfl.sh "projects/$proj" "$REPEAT" $proj "$LOGFILE"  >> "$LOGFILE"    
    fi

done
   
cd "$PATHLOCAL"/dotnet-sfl-tool/ || exit
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/byClass --order class
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/byScore --order score

timeNow=$(date +%Y-%m-%d_%H-%M-%S)
zip -r "$PATHLOCAL/test/log-$timeNow.zip" "$PATHLOCAL/test/" -x "*.zip"

cd "$PATHLOCAL"/test/ || exit
rm ./*.csv ./*.xml ./*.txt ./*.ser
rm -rf normalized
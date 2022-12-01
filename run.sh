#!/bin/sh

PATHLOCAL=$PWD
LOGFILE="$PWD/test/log.txt"

if [ ! -d "$PWD/test/" ]; then
        mkdir "$PWD/test/"
fi

for proj in 'JacksonDatabind80b' 'Math104b' 'JacksonXML2b' 'Compress47b' 'Codec18b' 'Csv1b' 'Jsoup93b' 'Time1b' 'Gson18b' 'Lang1b' 'Collections25b'
do
    echo "execution $proj"  >> "$LOGFILE"

    if [ $proj = 'Gson18b' ]; then
        bash ./sfl.sh "projects/$proj/gson" "$REPEAT" >> "$LOGFILE"    
    else
        bash ./sfl.sh "projects/$proj" "$REPEAT" >> "$LOGFILE"    
    fi

    cd "$PATHLOCAL" || exit
done
   
cd "$PATHLOCAL"/dotnet-sfl-tool/ || exit
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/

timeNow=$(date +%Y-%m-%d_%H-%M-%S)
zip -r "$PATHLOCAL/test/log-$timeNow.zip" "$PATHLOCAL/test/" -x "*.zip"

cd "$PATHLOCAL"/test/ || exit
rm ./*.csv ./*.xml ./*.txt ./*.ser
rm -rf normalized
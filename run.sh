#!/bin/sh

PATHLOCAL="$PWD"
TESTPATH="$PWD/test"
LOGFILE="$PWD/test/log.txt"
D4J_HOME="/defects4j"

# parameters: $path, $proj, $version, $REPEAT
runProject()
{
    path=$1
    proj=$2
    version=$3
    REPEAT=$4            
    i=0
    while [ $i -lt "$REPEAT" ]; do
        i=$((i + 1))
        bash ./jaguar2.sh "$path" "$proj" "$version" "$i" "$D4J_HOME" >> "$LOGFILE"
        bash ./jaguar.sh "$path" "$proj" "$version" "$i" "$D4J_HOME" >> "$LOGFILE"
        bash ./flacoco.sh "$path" "$proj" "$version" "$i" "$D4J_HOME" >> "$LOGFILE"
        bash ./gzoltarCLI.sh "$path" "$proj" "$version" "$i" "$D4J_HOME" >> "$LOGFILE"
        bash ./gzoltarMaven.sh "$path" "$proj" "$version" "$i" "$D4J_HOME" >> "$LOGFILE"
    done
}

if [ ! -d "$TESTPATH" ]; then
    mkdir "$TESTPATH"
fi

cd "$PATHLOCAL" || exit

runProject "$PATHLOCAL" "Csv" "1" "$REPEAT"
runProject "$PATHLOCAL" "JacksonDatabind" "80" "$REPEAT"
runProject "$PATHLOCAL" "Gson" "18" "$REPEAT"
runProject "$PATHLOCAL" "Math" "104" "$REPEAT"
runProject "$PATHLOCAL" "JacksonXML" "2" "$REPEAT"
runProject "$PATHLOCAL" "Compress" "47" "$REPEAT"
runProject "$PATHLOCAL" "Codec" "18" "$REPEAT"
runProject "$PATHLOCAL" "Jsoup" "93" "$REPEAT"
runProject "$PATHLOCAL" "Time" "1" "$REPEAT"
runProject "$PATHLOCAL" "Lang" "1" "$REPEAT"
runProject "$PATHLOCAL" "Collections" "25" "$REPEAT"

cd "$PATHLOCAL"/dotnet-sfl-tool/ || exit
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/byClass --order class
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/byScore --order score

timeNow=$(date +%Y-%m-%d_%H-%M-%S)
zip -r "$PATHLOCAL/test/log-$timeNow.zip" "$PATHLOCAL/test/" -x "*.zip"

cd "$PATHLOCAL"/test/ || exit
rm ./*.csv ./*.xml ./*.txt
rm -rf normalized
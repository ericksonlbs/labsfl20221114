#!/bin/sh

nanoToMili=1000000
work_dir="$1"
PID="$2"
BID="$3"
COUNT="$4"
D4J_HOME="$5"
PREFIX="$work_dir/test/${PID}_${BID}b"
projD4J="$work_dir/projects/${PID}${BID}"
RESULT="$work_dir/test/execution.csv"

echo "Start Flacoco - ${PID}${BID}b - ${COUNT}"

#define MAVEN_OPTS to memory start and limit
export _JAVA_OPTIONS="-Xmx6144M -XX:MaxHeapSize=4096M"
export MAVEN_OPTS="-Xmx6144M"

cd "$projD4J" || exit

if [ "${PID}" = "Gson" ]; then
    projD4J="$projD4J/gson"
fi

mvn clean
start=$(date +%s%N)
mvn process-test-classes

end=$(date +%s%N)
TIMECOMPILE=$(((end - start) / nanoToMili))

src_classes_dir=$("$D4J_HOME/framework/bin/defects4j" export -p dir.bin.classes)
src_classes_dir="$projD4J/$src_classes_dir"
test_classes_dir=$("$D4J_HOME/framework/bin/defects4j" export -p dir.bin.tests)
test_classes_dir="$projD4J/$test_classes_dir"

start=$(date +%s%N)
java -jar ~/.m2/repository/com/github/spoonlabs/flacoco/1.0.6-SNAPSHOT/flacoco-1.0.6-SNAPSHOT-jar-with-dependencies.jar \
        --projectpath "$projD4J" \
        -o target/flacoco.csv  
end=$(date +%s%N)
TIMECLI=$(((end - start) / nanoToMili))
fileGenerated="false"

nameFileGenerated="target/flacoco.csv" 

if [ -f "$nameFileGenerated" ]; then
    myfilesize=$(stat --format=%s "$nameFileGenerated")
    size=$(wc -l "$nameFileGenerated")
    if [ "${myfilesize}" != "0" ]; then
        if [ "${size}" != "1 $nameFileGenerated" ]; then
            fileGenerated="true"
        fi
    fi
fi


if [ ! -f "$RESULT" ]; then
    echo "application;project;bug id;count;compile;execution;sum;fileGenerated" >> "$RESULT"
fi
echo "Flacoco;$PID;$BID;$COUNT;$TIMECOMPILE;$TIMECLI;$((TIMECOMPILE + TIMECLI));$fileGenerated" >> "$RESULT"


echo "$PREFIX-$COUNT-flacoco.csv"
cp "target/flacoco.csv" "$PREFIX-$COUNT-flacoco.csv"

echo "Final Flacoco - ${PID}${BID}b - ${COUNT}"
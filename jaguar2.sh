#!/bin/sh

nanoToMili=1000000
work_dir="$1"
PID="$2"
BID="$3"
COUNT="$4"
PREFIX="$work_dir/test/${PID}_${BID}b"
projD4J="$work_dir/projects/${PID}${BID}b"
RESULT="$work_dir/test/execution.csv"

echo "Start Jaguar2 - ${PID}${BID}b - ${COUNT}"
#define MAVEN_OPTS to memory start and limit
export _JAVA_OPTIONS="-Xmx6144M -XX:MaxHeapSize=4096M"
export MAVEN_OPTS="-Xmx6144M"

if [ "${PID}" = "Gson" ]; then
    projD4J="$projD4J/gson"
fi

cd "$projD4J" || exit

#compile first time to cache dependencies
if [ "${COUNT}" = "1" ]; then
    mvn -f pom-jaguar.xml compile
fi

mvn clean
start=$(date +%s%N)
mvn -f pom-jaguar.xml verify
end=$(date +%s%N)
TIMECLI=$(((end - start) / nanoToMili))
fileGenerated="false"
if [ -f "target/jaguar2.csv" ]; then
    myfilesize=$(stat --format=%s "target/jaguar2.csv")
    if [ "${myfilesize}" != "0" ]; then
        fileGenerated="true"
    fi
fi

if [ ! -f "$RESULT" ]; then
    echo "application;project;bug id;count;compile;execution;sum;fileGenerated" >>"$RESULT"
fi
echo "Jaguar2;$PID;$BID;$COUNT;0;$TIMECLI;$((TIMECLI));$fileGenerated" >>"$RESULT"

cp "target/jaguar2.csv" "$PREFIX-$COUNT-jaguar2.csv"

echo "Final Jaguar2 - ${PID}${BID}b - ${COUNT}"

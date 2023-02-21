#!/bin/sh

nanoToMili=1000000
work_dir="$1"
PID="$2"
BID="$3"
COUNT="$4"
D4J_HOME="$5"
PREFIX="$work_dir/test/${PID}_${BID}b"
RESULT="$work_dir/test/execution.csv"
projD4J="$work_dir/projects/${PID}${BID}"

echo "Start Jaguar - ${PID}${BID}b - ${COUNT}"
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

if [ "${PID}" = "Lang" ]; then
    "$D4J_HOME/framework/bin/defects4j" compile
fi
if [ "${PID}" = "Collections" ]; then
    "$D4J_HOME/framework/bin/defects4j" compile
fi

# test_classpath=$($D4J_HOME/framework/bin/defects4j export -p cp.test)
src_classes_dir=$($D4J_HOME/framework/bin/defects4j export -p dir.bin.classes)
src_classes_dir="$projD4J/$src_classes_dir"
test_classes_dir=$($D4J_HOME/framework/bin/defects4j export -p dir.bin.tests)
test_classes_dir="$projD4J/$test_classes_dir"

JAGUAR_JAR="$HOME/.m2/repository/br/usp/each/saeg/jaguar/br.usp.each.saeg.jaguar.core/1.0.0/br.usp.each.saeg.jaguar.core-1.0.0-jar-with-dependencies.jar"
JACOCO_JAR="$HOME/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar"

LOG_LEVEL="ERROR" # ERROR / INFO / DEBUG / TRACE

start=$(date +%s%N)
java -javaagent:"$JACOCO_JAR"=output=tcpserver -cp "$src_classes_dir"/:"$test_classes_dir":"$JAGUAR_JAR":"$JACOCO_JAR" \
    "br.usp.each.saeg.jaguar.core.cli.JaguarRunner" \
    --outputType F \
    --output "control-flow" \
    --logLevel "$LOG_LEVEL" \
    --projectDir "$projD4J" \
    --classesDir "$src_classes_dir" \
    --testsDir "$test_classes_dir" \
    --testsListFile "$projD4J/testListFile.txt" \
    --heuristic "Ochiai" 
end=$(date +%s%N)
TIMECLI=$(((end - start) / nanoToMili))
fileGenerated="false"


if [ "${PID}" = "Gson" ]; then
    nameFileGenerated="gson/.jaguar/control-flow.xml"
else
    nameFileGenerated=".jaguar/control-flow.xml"
fi

if [ -f $nameFileGenerated ]; then
    myfilesize=$(stat --format=%s "$nameFileGenerated")
    size=$(wc -l $nameFileGenerated)
    if [ "${myfilesize}" != "0" ]; then
        if [ "${size}" != "2 $nameFileGenerated" ]; then
            fileGenerated="true"
        fi
    fi
fi

if [ ! -f "$RESULT" ]; then
    echo "application;project;bug id;count;compile;execution;sum;fileGenerated" >> "$RESULT"
fi
echo "Jaguar;$PID;$BID;$COUNT;$TIMECOMPILE;$TIMECLI;$((TIMECOMPILE + TIMECLI));$fileGenerated" >> "$RESULT"

cp $nameFileGenerated "$PREFIX-$COUNT-jaguar-control-flow.xml"


echo "Final Jaguar - ${PID}${BID}b - ${COUNT}"
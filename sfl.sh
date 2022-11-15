#!/bin/sh

execute() {
    i=0
    guid=$(uuidgen)

    resultPath="$PWD/test"

    if [ -n "${1}" ]; then
        path=$1
    else
        path=$HOME
    fi  

    if [ -n "${2}" ]; then
        max=$2
    else
        max=20
    fi 

    if [ ! -d "$resultPath" ]; then
        mkdir "$resultPath"
    fi
    
    cd "$path" || exit

    prefix=$resultPath/${PWD##*/}-$guid
    
    while [ $i -lt $max ]; do

        i=$((i + 1))

        startmain=$(date +%s%N)
        nanoToMili=1000000

        #clean
        mvn clean

        #flacoco pre vuild
        start=$(date +%s%N)
        mvn verify
        end=$(date +%s%N)

        build=$(((end - start) / nanoToMili))

        #flacoco sfl
        start=$(date +%s%N)
        java -jar ~/.m2/repository/com/github/spoonlabs/flacoco/1.0.6-SNAPSHOT/flacoco-1.0.6-SNAPSHOT-jar-with-dependencies.jar --projectpath . -o target/flacoco.csv # -v --testRunnerVerbose
        end=$(date +%s%N)
        flacoco=$(((end - start) / nanoToMili))
        #print flacoco
        cat target/flacoco.csv
        cp "target/flacoco.csv" "$prefix-$i-flacoco.csv"

        #jaguar sfl
        start=$(date +%s%N)
        PROJECT_DIR="$PWD"
        JAGUAR_JAR="$HOME/.m2/repository/br/usp/each/saeg/jaguar/br.usp.each.saeg.jaguar.core/1.0.0/br.usp.each.saeg.jaguar.core-1.0.0-jar-with-dependencies.jar"
        JACOCO_JAR="$HOME/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar"
        LOG_LEVEL="ERROR" # ERROR / INFO / DEBUG / TRACE

        java -javaagent:"$JACOCO_JAR"=output=tcpserver -cp "$PROJECT_DIR"/target/classes/:"$PROJECT_DIR"/target/test-classes/:"$JAGUAR_JAR":"$JACOCO_JAR" \
            "br.usp.each.saeg.jaguar.core.cli.JaguarRunner" \
            --outputType F \
            --output "control-flow" \
            --logLevel "$LOG_LEVEL" \
            --projectDir "$PROJECT_DIR" \
            --classesDir "$PROJECT_DIR/target/classes/" \
            --testsDir "$PROJECT_DIR/target/test-classes/" \
            --testsListFile "$PROJECT_DIR/testListFile.txt" \
            --heuristic "Ochiai"
        end=$(date +%s%N)
        jaguar=$(((end - start) / nanoToMili))

        cp ".jaguar/control-flow.xml" "$prefix-$i-jaguar-control-flow.xml"

        #clean
        mvn clean

        #jaguar2
        start=$(date +%s%N)
        mvn -f pom-jaguar.xml verify
        end=$(date +%s%N)
        jaguar2=$(((end - start) / nanoToMili))
        #print jaguar2
        cat target/jaguar2.csv
        cp "target/jaguar2.csv" "$prefix-$i-jaguar2.csv"

        end=$(date +%s%N)

        runtime=$(((end - startmain) / nanoToMili))

        buildJaguar=$((build + jaguar))
        buildFlacoco=$((build + flacoco))

        file="$prefix-execution.csv"
        if [ ! -f "$file" ]; then
            echo "application;execution;number;build;flacoco;build+flacoco;jaguar;build+jaguar;build with jaguar2;total time" >>"$file"
        fi

        echo "${PWD##*/};$guid;$i/$max;$build;$flacoco;$buildFlacoco;$jaguar;$buildJaguar;$jaguar2;$runtime" >>"$file"
    done
}

execute "$@"
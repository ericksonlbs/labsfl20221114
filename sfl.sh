#!/bin/sh

execute() {
    i=0
    guid=$(uuidgen)

    #define MAVEN_OPTS to memory start and limit
    export MAVEN_OPTS="-Xms7168m -Xmx7168m"

    resultPath="$PWD/test"

    if [ -n "${1}" ]; then
        path=$1
    else
        path=$HOME
    fi  

    if [ -n "${2}" ]; then
        repeat=$2
    else
        repeat=1
    fi 

    if [ ! -d "$resultPath" ]; then
        mkdir "$resultPath"
    fi
    
    cd "$path" || exit

    prefix=$resultPath/${PWD##*/}-$guid
    
    while [ $i -lt $repeat ]; do

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
        java -Xms7168m -Xmx7168m -jar ~/.m2/repository/com/github/spoonlabs/flacoco/1.0.6-SNAPSHOT/flacoco-1.0.6-SNAPSHOT-jar-with-dependencies.jar \
            --projectpath . \
            -o target/flacoco.csv  
            
        end=$(date +%s%N)
        flacoco=$(((end - start) / nanoToMili))
        sort --field-separator=',' --key=3 -r "target/flacoco.csv" > "$prefix-$i-flacoco.csv"

        #jaguar sfl
        start=$(date +%s%N)
        PROJECT_DIR="$PWD"
        JAGUAR_JAR="$HOME/.m2/repository/br/usp/each/saeg/jaguar/br.usp.each.saeg.jaguar.core/1.0.0/br.usp.each.saeg.jaguar.core-1.0.0-jar-with-dependencies.jar"
        JACOCO_JAR="$HOME/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar"
        LOG_LEVEL="ERROR" # ERROR / INFO / DEBUG / TRACE

        java -Xms7168m -Xmx7168m -javaagent:"$JACOCO_JAR"=output=tcpserver -cp "$PROJECT_DIR"/target/classes/:"$PROJECT_DIR"/target/test-classes/:"$JAGUAR_JAR":"$JACOCO_JAR" \
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

        mvn clean

        #jaguar2
        start=$(date +%s%N)
        mvn -f pom-jaguar.xml verify
        end=$(date +%s%N)
        jaguar2=$(((end - start) / nanoToMili))
        sort --field-separator=',' --key=7 -r "target/jaguar2.csv" > "$prefix-$i-jaguar2.csv"

        mvn clean

        #gzoltar
        start=$(date +%s%N)
        mvn -f pom-gzoltar.xml verify
        mvn -f pom-gzoltar.xml gzoltar:fl-report
        end=$(date +%s%N)
        gzoltar=$(((end - start) / nanoToMili))
        sort --field-separator=';' --key=2 -r "target/site/gzoltar/sfl/txt/ochiai.ranking.csv" > "$prefix-$i-gzoltar.ochiai.ranking.csv"
                      
        end=$(date +%s%N)
        runtime=$(((end - startmain) / nanoToMili))
        buildJaguar=$((build + jaguar))
        buildFlacoco=$((build + flacoco))

        file="$prefix-execution.csv"
        if [ ! -f "$file" ]; then
            echo "application;execution;number;build;flacoco;jaguar;build+flacoco;build+jaguar;build with jaguar2;gzoltar;total time" >> "$file"
        fi

        echo "${PWD##*/};$guid;$i of $repeat;$build;$flacoco;$jaguar;$buildFlacoco;$buildJaguar;$jaguar2;$gzoltar;$runtime" >> "$file"
    done
}

execute "$@"

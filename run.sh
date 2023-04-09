#!/bin/sh

PATHLOCAL="$PWD"
TESTPATH="$PWD/test"
LOGFILE="$PWD/test/log.txt"
D4J_HOME="/defects4j"
# nanoToMili=1000000

# parameters: $path, $proj, $version, $REPEAT
runProject()
{
    path=$1
    proj=$2
    version=$3
    REPEAT=$4            
    TOOL=$5
    i=0
    
    #checkout project
    $D4J_HOME/framework/bin/defects4j checkout -p "$proj" -v "${version}b" -w "/labsfl20221114/projects/${proj}${version}"

    # enter path
    if [ "${proj}" = "Gson" ]; then        
        cd "$path/projects/${proj}${version}/gson" || exit
    else
        cd "$path/projects/${proj}${version}" || exit
    fi

    #fixed project to build in maven    
    if [ "${proj}" = "JacksonDatabind" ]; then   
        rm "$path/projects/${proj}${version}/src/main/java/com/fasterxml/jackson/databind/cfg/PackageVersion.java"
    else
        if [ "${proj}" = "JacksonXml" ]; then       
            rm pom.xml
            cp "$path/projects/${proj}${version}b/pom.xml" "$path/projects/${proj}${version}/pom.xml"
        else
            if [ "${proj}" = "Lang" ]; then       
                rm "$path/projects/${proj}${version}/src/test/java/org/apache/commons/lang3/reflect/TypeUtilsTest.java"
            fi
        fi
    fi   
    
    # first build to cache mvn dependencies
    echo "First build $PWD" >> "$LOGFILE"
    mvn verify
    mvn clean
    echo "End First build $PWD" >> "$LOGFILE"
    
   
    if [ -z "${TOOL}" ] || [ "${TOOL}" = "JAGUAR2" ]; then      
        # first build jaguar 2 to cache mvn dependencies
        echo "First build Jaguar 2" >> "$LOGFILE"    
        if [ "${proj}" = "Gson" ]; then        
            cp "$path/projects/${proj}${version}b/gson/pom-jaguar.xml" "$path/projects/${proj}${version}/gson/pom-jaguar.xml"
        else    
            cp "$path/projects/${proj}${version}b/pom-jaguar.xml" "$path/projects/${proj}${version}/pom-jaguar.xml"
        fi
        mvn -f pom-jaguar.xml verify
        mvn clean
    fi

    if [ -z "${TOOL}" ] || [ "${TOOL}" = "GZOLTARMAVEN" ]; then
        # first build gzoltar to cache mvn dependencies    
        echo "First build GZoltar(Maven)" >> "$LOGFILE"
        if [ "${proj}" = "Gson" ]; then        
            cp "$path/projects/${proj}${version}b/gson/pom-gzoltar.xml" "$path/projects/${proj}${version}/gson/pom-gzoltar.xml"
        else    
            cp "$path/projects/${proj}${version}b/pom-gzoltar.xml" "$path/projects/${proj}${version}/pom-gzoltar.xml"
        fi
        mvn -f pom-gzoltar.xml verify
        mvn clean
    fi
        
    # RESULT="$path/test/execution.csv"

    while [ $i -lt "$REPEAT" ]; do
        i=$((i + 1))
        {   
            mvn clean            
            if [ -z "${TOOL}" ] || [ "${TOOL}" = "VERIFY" ]; then
                bash "$path/verify.sh" "$path" "$proj" "$version" "$i" "$D4J_HOME"
            fi
            if [ -z "${TOOL}" ] || [ "${TOOL}" = "JAGUAR" ]; then
                bash "$path/jaguar.sh" "$path" "$proj" "$version" "$i" "$D4J_HOME"
            fi
            if [ -z "${TOOL}" ] || [ "${TOOL}" = "FLACOCO" ]; then
                bash "$path/flacoco.sh" "$path" "$proj" "$version" "$i" "$D4J_HOME"
            fi
            if [ -z "${TOOL}" ] || [ "${TOOL}" = "GZOLTARCLI" ]; then
                bash "$path/gzoltarCLI.sh" "$path" "$proj" "$version" "$i" "$D4J_HOME"
            fi
            if [ -z "${TOOL}" ] || [ "${TOOL}" = "JAGUAR2" ]; then
                bash "$path/jaguar2.sh" "$path" "$proj" "$version" "$i" "$D4J_HOME"
            fi
            if [ -z "${TOOL}" ] || [ "${TOOL}" = "GZOLTARMAVEN" ]; then
                bash "$path/gzoltarMaven.sh" "$path" "$proj" "$version" "$i" "$D4J_HOME"
            fi
        } >> "$LOGFILE"
    done
}

if [ ! -d "$TESTPATH" ]; then
    mkdir "$TESTPATH"
fi

cd "$PATHLOCAL" || exit

if [ -n "${PROJECT}" ] && [ -n "${VERSION}" ] && [ -n "${TOOL}" ]; then    
    runProject "$PATHLOCAL" "$PROJECT" "$VERSION" "$REPEAT" "$TOOL"
else
    runProject "$PATHLOCAL" "Codec" "18" "$REPEAT" ""
    runProject "$PATHLOCAL" "Collections" "25" "$REPEAT" ""
    runProject "$PATHLOCAL" "Compress" "47" "$REPEAT" ""
    runProject "$PATHLOCAL" "Csv" "1" "$REPEAT" ""
    runProject "$PATHLOCAL" "Gson" "18" "$REPEAT" ""
    runProject "$PATHLOCAL" "JacksonDatabind" "80" "$REPEAT" ""
    runProject "$PATHLOCAL" "JacksonXml" "2" "$REPEAT" ""
    runProject "$PATHLOCAL" "Jsoup" "93" "$REPEAT" ""
    runProject "$PATHLOCAL" "Lang" "1" "$REPEAT" ""
    runProject "$PATHLOCAL" "Math" "104" "$REPEAT" ""
    runProject "$PATHLOCAL" "Time" "1" "$REPEAT" ""
fi

cd "$PATHLOCAL"/dotnet-sfl-tool/ || exit
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/byClass --order class
dotnet run --inputPath /labsfl20221114/test --outputPath /labsfl20221114/test/normalized/byScore --order score

timeNow=$(date +%Y-%m-%d_%H-%M-%S)
zip -r "$PATHLOCAL/test/log-$timeNow.zip" "$PATHLOCAL/test/" -x "*.zip"

cd "$PATHLOCAL"/test/ || exit
rm ./*.csv ./*.xml ./*.txt
rm -rf normalized
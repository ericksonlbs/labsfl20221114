ARG REPEAT=1
FROM openjdk:8

#Amount repetitions for each project
ENV REPEAT=${REPEAT}

# Update aptitude with new repo
RUN apt-get update -y

# Install dependencies
RUN apt-get install -y git maven uuid-runtime zip libdbi-perl libtext-csv-perl libdbd-csv-perl libjson-parse-perl

#install Jaguar
RUN git clone https://github.com/saeg/jaguar
WORKDIR /jaguar
RUN mvn install:install-file -Dfile=br.usp.each.saeg.jaguar.core/lib/org.jacoco.core-0.7.6.jar \
            -DgroupId=br.usp.each.saeg -DartifactId=org.jacoco.core \
            -Dversion=0.7.6 -Dpackaging=jar
RUN mvn clean install -pl br.usp.each.saeg.jaguar.codeforest -pl br.usp.each.saeg.jaguar.core -Dmaven.test.skip
WORKDIR /
RUN rm -rf jaguar

# Install dependencies
RUN apt-get install -y openjdk-11-jdk

#install flacoco
RUN git clone https://github.com/spoonlabs/flacoco
WORKDIR /flacoco
RUN mvn install -Dmaven.test.skip
WORKDIR /    
RUN rm -rf flacoco

#install Jaguar2
RUN git clone https://github.com/saeg/jaguar2
WORKDIR /jaguar2
RUN mvn clean install --projects '!jaguar2-examples,!jaguar2-validations,!jaguar2-examples/jaguar2-example-junit,!jaguar2-examples/jaguar2-example-junit-jacoco,!jaguar2-examples/jaguar2-example-junit-ba-dua'  -Dmaven.test.skip
WORKDIR /
RUN rm -rf jaguar2

#install GZoltar
RUN git clone https://github.com/GZoltar/gzoltar
WORKDIR /gzoltar
RUN mvn clean install -Dmaven.test.skip
RUN mvn clean package -Dmaven.test.skip
WORKDIR /

#install defects4j
RUN git clone https://github.com/rjust/defects4j.git
WORKDIR /defects4j
RUN ./init.sh
WORKDIR /

#prepare dotnet-sfl-tool
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update && apt-get install -y dotnet-sdk-6.0
COPY dotnet-sfl-tool labsfl20221114/dotnet-sfl-tool
WORKDIR /labsfl20221114/dotnet-sfl-tool
RUN dotnet build

#copy files
COPY projects /labsfl20221114/projects
COPY run.sh /labsfl20221114
COPY sfl.sh /labsfl20221114
COPY gzoltarMaven.sh /labsfl20221114
COPY gzoltarCLI.sh /labsfl20221114
COPY jaguar.sh /labsfl20221114
COPY jaguar2.sh /labsfl20221114
COPY flacoco.sh /labsfl20221114

#set workdir
WORKDIR /labsfl20221114

CMD ["bash", "./run.sh"]
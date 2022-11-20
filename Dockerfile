ARG REPEAT=1
FROM openjdk:8

#Amount repetitions for each project
ENV REPEAT=${REPEAT}

# Update aptitude with new repo
RUN apt-get update -y

# Install dependencies
RUN apt-get install -y git maven uuid-runtime zip

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
WORKDIR /
RUN rm -rf gzoltar

#copy files
COPY projects labsfl20221114/projects
COPY run.sh labsfl20221114
COPY sfl.sh labsfl20221114

#set workdir
WORKDIR /labsfl20221114

CMD ["bash", "./run.sh"]
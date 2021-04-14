FROM       ubuntu:20.04
MAINTAINER arknell@yonsei.ac.kr

# update pacakge
RUN apt update
RUN apt-get update

# install application for project
RUN apt -y install git
RUN DEBIAN_FRONTEND="noninteractive" TZ="Asia/Seoul" apt -y install nodejs
RUN apt -y install openjdk-8-jdk
RUN apt -y install maven
RUN apt -y install tomcat9 tomcat9-admin
RUN apt -y install npm

WORKDIR /usr/src/app

# clone the projects
RUN git clone https://github.com/OHDSI/Atlas.git
RUN git clone https://github.com/OHDSI/WebAPI.git

# copy config-document
COPY ./WebAPI/ /usr/src/app/WebAPI/
COPY ./Atlas/ /usr/src/app/Atlas/js/

# build projects
WORKDIR /usr/src/app/Atlas
RUN npm run build
WORKDIR /usr/src/app/WebAPI
ARG WEBAPI_DATASOURCE_PROFILE=webapi-postgresql
RUN mvn clean package -Dmaven.test.skip=true -s WebAPIConfig/settings.xml -P ${WEBAPI_DATASOURCE_PROFILE}

# deploy projects
RUN mkdir /usr/share/tomcat9/logs
RUN chmod 777 /usr/share/tomcat9/logs
RUN mkdir /usr/share/tomcat9/webapps
RUN chmod 777 /usr/share/tomcat9/webapps

RUN ln -s /var/lib/tomcat9/conf /usr/share/tomcat9/conf

RUN cp -rf /usr/src/app/Atlas /usr/share/tomcat9/webapps/
RUN cp -rf /usr/src/app/WebAPI/target/WebAPI.war /usr/share/tomcat9/webapps/

EXPOSE 8080
ENTRYPOINT /usr/share/tomcat9/bin/catalina.sh run

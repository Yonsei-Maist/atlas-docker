FROM       ubuntu:20.04
MAINTAINER arknell@yonsei.ac.kr

# update pacakge
RUN apt update
RUN apt-get update

# install application for project
RUN apt -y install git
RUN apt -y install nodejs
RUN apt -y install default-jre
RUN apt -y install maven
RUN apt -y install tomcat9 tomcat9-admin

WORKDIR /usr/src/app

# clone the projects
RUN git clone https://github.com/OHDSI/Atlas.git
RUN git clone https://github.com/OHDSI/WebAPI.git

# copy config-item
COPY ./atlas/WebAPI/ /usr/src/app/WebAPI/
COPY ./atlas/Atlas/ /usr/src/app/Atlas/js/

# build projects
WORKDIR /usr/src/app/Atlas
RUN npm install
WORKDIR /usr/src/app/WebAPI
ARG WEBAPI_DATASOURCE_PROFILE=webapi-postgresql
RUN mvn clean package -DskipTests -s WebAPIConfig/settings.xml -P ${WEBAPI_DATASOURCE_PROFILE}

# deploy projects
RUN systemctl start tomcat9
RUN cp -rf /usr/src/app/Atlas /var/lib/tomcat9/webapps/
RUN cp -rf /usr/src/app/WebAPI/target/WebAPI.war /var/lib/tomcat9/webapps/

EXPOSE 8080
ENTRYPOINT systemctl restart tomcat9 

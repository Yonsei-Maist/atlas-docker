FROM       ubuntu:20.04
MAINTAINER arknell@yonsei.ac.kr

# update pacakge
RUN apt update
RUN apt-get update

# install application for project
RUN apt -y install git
RUN apt -y install nodejs
RUN apt install tomcat9 tomcat9-admin

WORKDIR /usr/src/app

# clone the projects
RUN git clone https://github.com/OHDSI/Atlas.git
RUN git clone https://github.com/OHDSI/WebAPI.git

# copy config-item
COPY ./atlas/WebAPI/ /usr/src/app/WebAPI/
COPY ./atlas/Atlas/ /usr/src/app/Atlas/js/

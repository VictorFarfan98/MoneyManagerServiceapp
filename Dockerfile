FROM node:10

RUN echo "UTC" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update
RUN apt-get -y install mysql-client
#RUN apt-get -y install detox

# make temp dirs
RUN mkdir /usr/temp
#RUN mkdir /usr/dumps
#RUN mkdir /usr/dumps/complete
#RUN mkdir /usr/dumps/inc
#RUN mkdir /usr/dumps/backups

COPY ["package.json", "package-lock.json", "/usr/src/"]
WORKDIR /usr/src
RUN npm install

COPY [".", "/usr/src"]

# permissions to executable
RUN chmod a+x /usr/src/src/bash_scripts/sql-batch.sh
#RUN chmod a+x /usr/src/src/bash_scripts/compress_csv.sh
#RUN chmod a+x /usr/src/src/bash_scripts/detox.sh
#RUN chmod a+x /usr/src/src/bash_scripts/download_sftp.sh
#RUN chmod a+x /usr/src/src/bash_scripts/entry_point_etl.sh
#RUN chmod a+x /usr/src/src/bash_scripts/upload_backup.sh
#RUN chmod a+x /usr/src/src/bash_scripts/load-all-csv.sh
#RUN chmod a+x /usr/src/src/bash_scripts/load-csv.sh

# fix end of file termination (issue when developing with windows)
RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/sql-batch.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/compress_csv.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/detox.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/download_sftp.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/entry_point_etl.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/upload_backup.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/load-all-csv.sh
#RUN sed -i 's/\r//g' /usr/src/src/bash_scripts/load-csv.sh

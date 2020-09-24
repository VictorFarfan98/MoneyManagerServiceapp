#!/bin/sh

FILES=$1
COUNT=0
for filename in $FILES/*.sql;
do   
    COUNT=$((COUNT+1))
    sed -e "s/\${DB_CONFIG}/$DB_CONFIG/" -e "s/\${DB_STAGE}/$DB_STAGE/" -e "s/\${DB_MAIN}/$DB_MAIN/" $filename  > /usr/temp/$COUNT.sql
    mysql -u $DB_USER -h $DB_HOST -p"$DB_PASS" < /usr/temp/$COUNT.sql
    echo "file execution complete" /usr/temp/$COUNT.sql
done

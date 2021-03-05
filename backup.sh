#!/bin/bash

FILE=backup.sql.`date +"%Y%m%d"`
USER=${DB_USER}
# (2) in case you run this more than once a day, remove the previous version of the file
# unalias rm     2> /dev/null
# rm ${FILE}     2> /dev/null
# rm ${FILE}.gz  2> /dev/null
sudo mkdir -p /opt/backups/ 
mysqldump --opt --user=root --password ${DATABASE} > ${FILE}
mv ${FILE} /opt/backups/
gzip $FILE
echo "${FILE}.gz was created:"
ls -l ${FILE}.gz
#!/bin/bash

# force language for lutece...
export LANG="fr_FR.UTF-8"
export LC_CTYPE="fr_FR.UTF-8"
export LC_NUMERIC="fr_FR.UTF-8"
export LC_TIME="fr_FR.UTF-8"
export LC_COLLATE="fr_FR.UTF-8"
export LC_MONETARY="fr_FR.UTF-8"
export LC_MESSAGES="fr_FR.UTF-8"
export LC_PAPER="fr_FR.UTF-8"
export LC_NAME="fr_FR.UTF-8"
export LC_ADDRESS="fr_FR.UTF-8"
export LC_TELEPHONE="fr_FR.UTF-8"
export LC_MEASUREMENT="fr_FR.UTF-8"
export LC_IDENTIFICATION="fr_FR.UTF-8"

IP="$(ip a s eth0 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | head -1)"
BASE_SCHEMA="`echo ${BASE_SCHEMA:-http} | tr '[:upper:]' '[:lower:]'`"
BASE_HOST="`echo ${BASE_HOST:-$IP} | tr '[:upper:]' '[:lower:]'`"
BASE_PATH="${BASE_PATH:-gru}"
PORT=""
if [ "x$BASE_PORT" != "x" ]; then
	if [ $BASE_SCHEMA = "http" -a $BASE_PORT -ne 80 -o $BASE_SCHEMA = "https" -a $BASE_PORT -ne 443 ]; then
		PORT=":$BASE_PORT"
	fi
fi
BASE_URL="${BASE_SCHEMA}://${BASE_HOST}${PORT}/${BASE_PATH}"
/usr/bin/mysqld_safe &
for i in {30..0}; do
	if echo 'SELECT 1' | mysql &> /dev/null; then
		break
	fi
	sleep 1
done
if [ "$i" = 0 ]; then
	echo >&2 'MySQL init process failed.'
	exit 1
fi
mysql -e "CREATE DATABASE gru"
sed -i'' "s|http://localhost/gru|$BASE_URL|g" /tmp/dump.sql
sed -i'' "s|http://localhost/gru|$BASE_URL|g" /var/lib/tomcat7/webapps/gru/WEB-INF/conf/override/config.properties
mysql gru < /tmp/dump.sql


/usr/lib/jvm/default-java/bin/java -Djava.util.logging.config.file=/var/lib/tomcat7/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.awt.headless=true -Xmx512m -XX:+UseConcMarkSweepGC -Djdk.tls.ephemeralDHKeySize=2048 -Djava.endorsed.dirs=/usr/share/tomcat7/endorsed -classpath /usr/share/tomcat7/bin/bootstrap.jar:/usr/share/tomcat7/bin/tomcat-juli.jar -Dcatalina.base=/var/lib/tomcat7 -Dcatalina.home=/usr/share/tomcat7 -Djava.io.tmpdir=/tmp/tomcat7-tomcat7-tmp org.apache.catalina.startup.Bootstrap start

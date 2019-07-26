#! /bin/sh

if [[ -z "$HOSTNAME_FQDN" ]]; then
  export HOSTNAME_FQDN="https://${NAMESPACE}.web.cern.ch"
fi

# Copy all the custom configuration injected in folder /rundeck-config into
# $RDECK_BASE/server/config/ . If there are no files or they are empty, nothing
# is copied
if [ -n "$(ls -A /rundeck-config)" ]
then
  for f in /rundeck-config/*
  do
    if [ -s $f ]
    then
      envsubst < $f > $RDECK_CONFIG/`basename $f`
    fi
  done
fi

# Remove auth constraint from WEB-INF to run in preauthenticated mode
xmlstarlet ed -L -N x="http://java.sun.com/xml/ns/javaee" -d '//x:auth-constraint' /var/lib/rundeck/exp/webapp/WEB-INF/web.xml

source /etc/rundeck/profile
exec $rundeckd

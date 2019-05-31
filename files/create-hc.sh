#!/bin/bash

HC_SERVER=$1
BASE_DIR=$2
HOST_NAME=$3
OWNER=$4
MGT_IP=$5
PUBLIC_IP=$6
PRIVATE_IP=$7
LOGIN=$8
PASSWORD=$9
JBOSS_HOME="/opt/jboss-eap-7.0/"
HOST_SLAVE="$BASE_DIR/configuration/host-slave.xml"

function usage
{
  echo "Usage:"
  echo "create-hc.sh <hc-server> <base-dir> <host-name> <base-dir-owner> <management-ip> <public-ip> <private-ip> <login> <password>"
  echo "This script creates a new EAP 7 Host Controller."
  echo -e
}

function create_hc
{
  echo -e
  echo "  .  Creating the $BASE_DIR directory... "
  ssh root@$HC_SERVER "mkdir -p $BASE_DIR" &> /dev/null
  echo "  .  Copying configuration files to $BASE_DIR directory..."
  ssh root@$HC_SERVER "cp -rf $JBOSS_HOME/domain/* $BASE_DIR" &> /dev/null
  echo "  .  Configuring the host name to $HOST_NAME ..."
  ssh root@$HC_SERVER "sed -i 's/<host/<host name=\"$HOST_NAME\"/g' $HOST_SLAVE"
  echo "  .  Configuring the Management IP to $MGT_IP ..."
  ssh root@$HC_SERVER "sed -i 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:$MGT_IP/g' $HOST_SLAVE" &> /dev/null
  echo "  .  Configuring the Public IP to $MGT_IP ..."
  ssh root@$HC_SERVER "sed -i 's/jboss.bind.address:127.0.0.1/jboss.bind.address:$PUBLIC_IP/g' $HOST_SLAVE" &> /dev/null
  echo "  .  Configuring the Private IP to $PRIVATE_IP ..."
  ssh root@$HC_SERVER "sed -i '71i <interface name=\"private\"><inet-address value=\"\${jboss.bind.address:$PRIVATE_IP}\"/></interface> ' $HOST_SLAVE" &> /dev/null
  echo "  .  Configuring the $LOGIN login ..."
  ssh root@$HC_SERVER "sed -i 's/<remote security-realm=\"ManagementRealm\"/<remote security-realm=\"ManagementRealm\" username=\"$LOGIN\"/g' $HOST_SLAVE" &> /dev/null
  echo "  .  Configuring the password ..."
  ssh root@$HC_SERVER "sed -i 's/c2xhdmVfdXNlcl9wYXNzd29yZA==/$PASSWORD/g' $HOST_SLAVE " &> /dev/null
  echo "  .  Setting the owner to $OWNER"
  ssh root@$HC_SERVER "chown -R root:root $BASE_DIR"
  echo -e
  echo "  Done"
  echo -e
}

if [ $# -ne 9 ] ; then
  usage
  exit 7
else
  create_hc
fi

#!/bin/bash
BASEDIR=$(dirname $0)
echo "Updating configs..."
$BASEDIR/update_solr_configuration.sh /opt/solr/server/solr/configsets/_default $SOLR_URL
echo "Add Sitecore collections..."
echo "$BASEDIR/create_solr_collections.sh \"$(dirname $BASEDIR)/configuration/sc-configuration.json\" \"$SOLR_URL\""
$BASEDIR/create_solr_collections.sh "$(dirname $BASEDIR)/configuration/sc-configuration.json" "$SOLR_URL"
echo "Add xDB collections..."
echo "$BASEDIR/create_solr_collections.sh \"$(dirname $BASEDIR)/configuration/xdb-configuration.json\" \"$SOLR_URL\""
$BASEDIR/create_solr_collections.sh "$(dirname $BASEDIR)/configuration/xdb-configuration.json" "$SOLR_URL"
echo "Done!"
CONFIG_PATH=$1
SOLR_URL=$2

cp -r $CONFIG_PATH/* /tmp/solr/sitecore
mv /tmp/solr/sitecore/conf/solrconfig.xml /tmp/solrconfig.xml && sed s/update.autoCreateFields:true/update.autoCreateFields:false/g /tmp/solrconfig.xml > /tmp/solr/sitecore/conf/solrconfig.xml
mv /tmp/solr/sitecore/conf/managed-schema /tmp/managed-schema && xsltproc $(dirname $0)/managed-schema.xslt /tmp/managed-schema > /tmp/solr/sitecore/conf/managed-schema
curl -sSL "${SOLR_URL}/solr/admin/configs?action=DELETE&name=sitecore&omitHeader=true"
(cd /tmp/solr/sitecore/conf && zip -r - *) | curl -X POST --header "Content-Type:application/octet-stream" --data-binary @- "${SOLR_URL}/solr/admin/configs?action=UPLOAD&name=sitecore"

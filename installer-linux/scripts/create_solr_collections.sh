#!/bin/bash
JSON_PATH=$1
SOLR_URL=$2

JSON_VALUE=$(<$JSON_PATH)

echo $JSON_VALUE | jq -r '.indexes[]' | while read index
do
	curl -X POST -L "${SOLR_URL}/api/c" -H "Content-Type:application/json" -d "{ create:{ name: '${index}', config: 'sitecore', numShards: 1, replicationFactor: 2} }"
done
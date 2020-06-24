more $1 | jq '.indexes[]' | while read index
do
	curl -X POST -L $2/api/c -H "Content-Type:application/json" -d "{ create:{ name: '${index}', config: 'sitecore', numShards: 1, replicationFactor: 2} }"
done
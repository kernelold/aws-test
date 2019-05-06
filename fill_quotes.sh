#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo "provide URL"
    exit 1
fi
URL="$1"

IFS='"'
QUOTAS=$(cat sample-data/*)
for i in $QUOTAS ; do
echo "===$i==="
if [[ $i != "
" ]] && [[ $i != "\n" ]] && [[ $i != "" ]] ; then
echo $i
curl  -i -H "Accept: application/json" -H "X-HTTP-Method-Override: POST"  -X POST -d '{"quote":"'${i}'","category":"random"}' $URL
fi
done

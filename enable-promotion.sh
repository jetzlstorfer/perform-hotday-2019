#!/bin/bash
echo "Usage: ./enable-promotion.sh http://XX.XX.XX.XX/ 30"
echo "Press [CTRL+C] to stop."

if [ -z $1 ]
then
  echo "Please provide the url as parameter"
  echo ""
  echo "Usage: ./enable-promotion.sh http://XX.XX.XX.XX/ 30"
  exit 1
fi

if [ -z $2 ]
then
  echo "Please provide the percent as 2nd parameter"
  echo ""
  echo "Usage: ./enable-promotion.sh http://XX.XX.XX.XX/ 30"
  exit 1
fi

if [ -z $DT_TENANT_ID ]
then
  echo "DT_TENANT_ID not set. Please set environment variable accordingly."
  exit 1
fi

if [ -z $DT_API_TOKEN ]
then
  echo "DT_API_TOKEN not set. Please set environment variable accordingly."
  exit 1
fi

url=$1
percent=$2

echo "pushing deployment event to Dynatrace"

curl -X POST \
  "https://$DT_TENANT_ID.live.dynatrace.com/api/v1/events?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
        "eventType": "CUSTOM_CONFIGURATION",
        "attachRules": {
          "tagRule" : {
            "meTypes" : ["SERVICE"],
            "tags" : [ 
              {"context": "ENVIRONMENT", "key": "application", "value": "sockshop"},
              {"context": "CONTEXTLESS", "key": "service", "value": "carts"},
              {"context": "CONTEXTLESS", "key": "environment", "value": "production"}
            ]
          }
        },
        "description" : "Changed Promotion percentage",
        "configuration":"Promotion Percentage",
        "changed": '$percent',
        "source" : "Script",
        "customProperties":{
          "RemediationAction": "Disable Promotion in case of errors!",
          "RemediationUrl": "'$url'/carts/1/items/promotion/0",
          "RemediationProvider": "Ansible Tower",
          "Approver": "luke.wilson@example.com",
          "Comment": "Testing out the new promotion feature of Carts"
        }
     }'
echo ""

echo "turning promotion to $percent %..."
curl -X GET $url/carts/1/items/promotion/$percent

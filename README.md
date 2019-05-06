
# Quote application

Application to store quotes and sent randomly 

List of 3-party used:
```
github.com/gorilla/mux
github.com/aws/aws-sdk-go/aws
github.com/aws/aws-sdk-go/aws/session
github.com/guregu/dynamo
```
List of puppet modules used:
```
puppetlabs-docker_platform --version 2.2.1
```

## Deployment

login to AWS:
```
aws configure
```

To build image run:
```
docker_image.sh
```

To deploy stack run:
```
terraform init
terraform apply
```

### Flow of deployment
Insrances will be created by terraform. DNS name of balancer will be showed in outputs.
Then over userdata will be deployed puppet. 
If s3 contains `site.pp` it will be used for puppet, otherwise `site.pp` will be generated by userdata. 
Then Puppet will deploy all requements for start docker and then start docker image `577043135686.dkr.ecr.us-west-1.amazonaws.com/quoteapp:latest`


## Usage
You can use web form at <balancer_url>/ to add new quote.

to add new quote via url
```
curl -i -H "Accept: application/json" -H "X-HTTP-Method-Override: POST"  -X POST -d '{"quote":"some very meanful test","category":"awesome"}'   <balancer_url>/new
```
to read all quotas
```
curl   <balancer_url>/quotes
```
to read random quote
```
curl    <balancer_url>/quote
```

## Additional tools

You can use `./fill_quotes.sh` script to fill quotes from sample directory.

```
./fill_quotes.sh http://<APP_BALANCER_URL>/new
```



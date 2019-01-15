# Example multi-layer application 

In this example we compose native microservices communication with queues and channels. 

## Architecture structure

Microservices deployed to first node (`platform`):
* admin-gateway
* api-gateway
* demo-app

Microservices deployed to second node (`platform-2`):
* customer-bl
* ledger-bl
* statistics
* customer-dl
* ledger-dl

## Scripts

* `start.sh` - starts both nodes
* `stop.sh` - stops both nodes

## Building

To build project run command:

`mvn clean package`

## Deploying

**Important:** Remember to starts both nodes first.

`mvn pre-integration-test`

## Accessing example

Go to page: [http://localhost:8000/demo-app/](http://localhost:8000/demo-app/)

## For IntelliJ

**Important!** Do not import maven project. Just use File->Open and select downloaded directory.
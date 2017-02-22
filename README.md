# poks-service

> 🚧 WIP microservices with Golo

This is a sample of microservice written for **poks-server** (https://github.com/wey-yu/poks-server)

## Setup and run

⚠️ You need to set some environment variables:

```shell
#!/bin/bash

# SERVICE_CREDENTIALS is a kind of token or password (the poks-server has the same token)
export SERVICE_CREDENTIALS=canarybay
export PORT=9090
# EXPOSED_PORT is useful especially with containers
export EXPOSED_PORT=9090
export SERVER_URL=http://localhost:8080
export SERVICE_BASE_URL=http://localhost # without port
export SERVICE_NAME=calculator
export SERVICE_ID=42
export SERVICE_VERSION=1.0

mvn package
mvn exec:java
```

For more details see https://github.com/wey-yu/poks-service/blob/master/src/main/golo/main.golo 

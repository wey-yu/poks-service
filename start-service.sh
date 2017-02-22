#!/bin/bash
export SERVICE_CREDENTIALS=canarybay
export PORT=9090
export EXPOSED_PORT=9090
export SERVER_URL=http://localhost:8080
export SERVICE_BASE_URL=http://localhost # without port
export SERVICE_NAME=calculator
export SERVICE_ID=42
export SERVICE_VERSION=1.0

mvn package
mvn exec:java

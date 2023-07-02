FROM confluentinc/cp-kafka-connect-base:latest

COPY target/components/packages/my-connector-<version>.zip /tmp/my-connector-<version>.zip

RUN confluent-hub install --no-prompt /tmp/my-connector-<version>.zip
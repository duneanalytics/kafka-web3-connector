# Kafka Web3 Connector

Forked from https://github.com/satran004/kafka-web3-connector

This connector reads blocks or events from a web3 json rpc compatible blockchain (Example: Aion, Ethereum) and pushes them to Kafka.

There are two available source connectors
1. **Block Source Connector :** com.bloxbean.kafka.connectors.web3.source.blocks.BlockSourceConnector
2. **Event Logs Connector :** com.bloxbean.kafka.connectors.web3.source.events.EventSourceConnector

## Build

```shell
mvn clean package
````
        
## Running the Block Source connector

```$xslt
name=bloxbean-web3-source-connector
connector.class=com.bloxbean.kafka.connectors.web3.source.blocks.BlockSourceConnector
tasks.max=1
web3_rpc_url=http://<web3_rpc_host>:<port>
topic=web3-connect-test
#To publish transactions to a separate topic, uncomment the following line
#transaction_topic=aion-transactions
#Comma separated list of ignored fields from Block object.
#ignore_block_fields=logsBloom,extraData
#Comma separated ist of ignored field from Transaction object. Supported options: input
#ignore_transaction_fields=input
start_block=6106120
block_time=10
```

Build the connector before proceeding. This will copy the uber jar to `kafka-connect/jars`, which is mounted as a volume
on the kafka connect image. These will be auto-imported on launch of Kafka connect.
   
- Start Kafka stack
   
```shell
docker compose up
```

- Interact with Kafka connect to register the connector

Verify plugin was detected by Kafka Connect:

```http request
GET http://localhost:8083/connector-plugins
```

Register the block source connector:
```http request
POST http://localhost:8083/connectors
Content-Type: application/json

{
  "name": "bloxbean-web3-source-connector-latest-blocks",
  "config": {
    "connector.class": "com.bloxbean.kafka.connectors.web3.source.blocks.BlockSourceConnector",
    "tasks.max": 1,
    "web3_rpc_url": "http://<node>",
    "topic": "aion-latest-blocks",
    "transaction_topic": "aion-transactions",
    "ignore_block_fields": "logsBloom,extraData",
    "ignore_transaction_fields": "input",
    "start_block": 106332167,
    "block_time": 10,
    "no_of_blocks_for_finality": 0
  }
}
```

Replace `web3_rpc_url` with a valid node URL for your target EVM blockchain.

Remember to shut down. Consult [Kafka Connect documentation](https://docs.confluent.io/platform/current/connect/references/restapi.html#connectors) for more usage.

```http request
DELETE http://localhost:8083/connectors/bloxbean-web3-source-connector-latest-blocks
```

You can use ksql CLI to observe the topic:

```shell
docker exec --interactive --tty ksqldb ksql http://localhost:8088
```

```genericsql
PRINT "aion-latest-blocks" [FROM BEGINNING] [INTERVAL | SAMPLE interval] [LIMIT limit]
```

[See the reference](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/print/) for more commands.
     
## Running the Event Logs Source connector

```$xslt
name=bloxbean-web3-events-source-connector
connector.class=com.bloxbean.kafka.connectors.web3.source.events.EventSourceConnector
tasks.max=1
web3_rpc_url=http://<web3_rpc_host>:<port>
topic=web3-events
start_block=6117319
block_time=10
no_of_blocks_for_finality=30

event_logs_filter_addresses=0xa008e42a76e2e779175c589efdb2a0e742b40d8d421df2b93a8a0b13090c7cc8
event_logs_filter_topics=0x41445344656c6567617465640000000000000000000000000000000000000000

####################################################################################
# Target kafka topic's key
# Comma separated list of following options
# Options: blockNumber, logIndex, address, topic, transactionHash, transactionIndex
# Default: transactionHash,logIndex
####################################################################################
#event_logs_kafka_keys=  
```
   
Start the same way as the block source connector:

```http request
POST http://localhost:8083/connectors
Content-Type: application/json

{
  "name": "bloxbean-web3-events-connector",
  "config": {
    "connector.class": "com.bloxbean.kafka.connectors.web3.source.events.EventSourceConnector",
    "tasks.max": 1,
    "web3_rpc_url": "http://<node>",
    "topic": "aion-events",
    "start_block": 106332167,
    "block_time": 10,
    "no_of_blocks_for_finality": 0
  }
}
```

## Using Alchemy

Alchemy "super" nodes work well. Just use your account's HTTP URL in place of the rpc_url when setting up the connector.
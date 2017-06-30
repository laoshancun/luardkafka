
local BROKERS_ADDRESS = { "localhost" }
local TOPIC_NAME = "test_topic"


local config = require 'rdkafka.config'.create()

config["statistics.interval.ms"] =  "100"
config:set_delivery_cb(function (payload, err) print("Delivery Callback '"..payload.."'") end)
config:set_stat_cb(function (payload) print("Stat Callback '"..payload.."'") end)

local producer = require 'rdkafka.producer'.create(config)

for k, v in pairs(BROKERS_ADDRESS) do
    producer:brokers_add(v)
end

local topic_config = require 'rdkafka.topic_config'.create()
topic_config["auto.commit.enable"] = "true"

local topic = require 'rdkafka.topic'.create(producer, TOPIC_NAME, topic_config)

local KAFKA_PARTITION_UA = -1

for i = 0,10 do
    producer:produce(topic, KAFKA_PARTITION_UA, "this is test message"..tostring(i))
end

while producer:outq_len() ~= 0 do
    producer:poll(10)
end

-- using ssl
local kafka_config = require 'rdkafka.config'.create()
kafka_config["group.id"] =  "hualv-fes-static-file-generator"
--config["enable.auto.commit"] =  "true"
kafka_config["auto.commit.interval.ms"] =  "5000"
kafka_config["bootstrap.servers"] =  "SSL://kafka-broker-1:9093,SSL://kafka-broker-2:9093"
kafka_config["statistics.interval.ms"] =  "60000"
kafka_config["security.protocol"] =  "SSL"
kafka_config["ssl.ca.location"] =  "/path/to/ca.cer"
kafka_config["ssl.certificate.location"] =  "/path/to/client-cert.cer"
kafka_config["ssl.key.location"] =  "/path/to/client-key.pem"
kafka_config["ssl.key.password"] =  "client-key-password"
kafka_config:set_delivery_cb(function (payload, err) print("Delivery Callback '"..payload.."'") end)
kafka_config:set_stat_cb(function (payload) print("Stat Callback '"..payload.."'") end)

local producer = require 'rdkafka.producer'.create(kafka_config)

local topic_config = require 'rdkafka.topic_config'.create()
topic_config["auto.commit.enable"] = "true"
topic = require 'rdkafka.topic'.create(producer, "static", topic_config)

producer:produce(topic, -1, "message");
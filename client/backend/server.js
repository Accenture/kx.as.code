const express = require("express");
const request = require("request");
const fs = require("fs");
const app = express();
const { AMQPClient } = require("@cloudamqp/amqp-client");

const PORT = process.env.PORT || 5001;
const dataPath = "../src/data/combined-metadata-files.json";

async function run() {
  try {
    const amqp = new AMQPClient("amqp://test:test@localhost:15672");
    const conn = await amqp.connect();
    const ch = await conn.channel();
    const q = await ch.queue();
    const consumer = await q.subscribe({ noAck: true }, async (msg) => {
      console.log(msg.bodyToString());
      await consumer.cancel();
    });
    await q.publish("Hello World", { deliveryMode: 2 });
    await consumer.wait(); // will block until consumer is canceled or throw an error if server closed channel/connection
    await conn.close();
  } catch (e) {
    console.error("ERROR", e);
    e.connection.close();
    setTimeout(run, 1000); // will try to reconnect in 1s
  }
}

run();

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

app.route("/api/queues/:queue_name").get((req, res) => {
  console.log("get q triggered.");
  var url =
    "http://test:test@localhost:15672/api/queues/%2F/" +
    req.params.queue_name +
    "/get";

  var dataString =
    '{"vhost":"/","name":"' +
    req.params.queue_name +
    '","truncate":"50000","ackmode":"ack_requeue_true","encoding":"auto","count":"100"}';

  let options = {
    url: url,
    method: "POST",
    body: dataString,
  };

  request(options, (error, response, body) => {
    if (error || response.statusCode !== 200) {
      return res.status(500).json({ type: "error", message: error.message });
    }
    res.json(JSON.parse(body));
  });
});

//move queue endpoint
app.route("/api/move/:from_queue/:to_queue").get((req, res) => {
  console.log("move triggered.");
  var url =
    "http://test:test@localhost:15672/api/parameters/shovel/%2F/Move%20from%20" +
    req.params.from_queue;

  var dataString =
    '{"component":"shovel","vhost":"/","name":"Move from "' +
    req.params.from_queue +
    ',"value":{"src-uri":"amqp:///%2F","src-queue":"' +
    req.params.from_queue +
    '","src-protocol":"amqp091","src-prefetch-count":1000,"src-delete-after":"queue-length","dest-protocol":"amqp091","dest-uri":"amqp:///%2F","dest-add-forward-headers":false,"ack-mode":"on-confirm","dest-queue":"' +
    req.params.to_queue +
    '","src-consumer-args":{}}}';

  let options = {
    url: url,
    method: "PUT",
    body: dataString,
  };

  request(options, (error, response, body) => {
    if (error || response.statusCode !== 200) {
      return res.status(500).json({ type: "error", message: error });
    } else {
      res.json(JSON.parse(body));
    }
  });
});

app.get("/api/applications", (req, res) => {
  fs.readFile(dataPath, "utf8", (err, data) => {
    if (err) {
      throw err;
    }

    res.send(JSON.parse(data));
  });
});

app.get("/api/applications/:app_name", (req, res) => {
  console.log("get app triggered.");
  fs.readFile(dataPath, "utf8", (err, data) => {
    if (err) {
      throw err;
    }
    var fil = JSON.parse(data).filter((app) => {
      if (app.name === req.params.app_name) {
        return app;
      }
    });
    res.send(fil);
  });
});

app.listen(PORT, () => console.log(`listening on ${PORT}`));

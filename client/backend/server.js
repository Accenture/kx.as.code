const express = require("express");
const request = require("request");
const fs = require("fs");
const amqp = require("amqplib");

const app = express();

const PORT = process.env.PORT || 5001;
const dataPath = "../src/data/combined-metadata-files.json";

app.route("/api/msg").post((req, res) => {
  amqp.connect("amqp://localhost", (err, conn) => {
    conn.createChannel((err, ch) => {
      const q = "tmp_queue";

      ch.assertQueue(q, { durable: false });

      setTimeout(() => {
        const msg_obj = { personId: 1, field1: "lorem", field2: "ipsum" };

        const msg = JSON.stringify(msg_obj);

        ch.sendToQueue(q, Buffer.from(msg));

        console.log(` [X] Send ${msg}`);
      }, 6000);
    });

    // The connection will close in 10 seconds
    setTimeout(() => {
      conn.close();
    }, 10000);
  });

  res.send("The POST request is being processed!");
});

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

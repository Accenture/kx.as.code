const express = require("express");
const request = require("request");
const fs = require("fs");
const app = express();
// const mongoose = require("mongoose")

// MongoDB
// mongoose.connect("mongodb://localhost/subscribers", {useNewUrlParser: true })
// const db = mongoose.connection
// db.on("error", (error) => console.error(error))
// db.once("error", (error) => console.error(error))

const PORT = process.env.PORT || 5001;
const dataPath = "../src/data/combined-metadata-files.json";

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

app.route("/api/queues/:queue_name").get((req, res) => {
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
      return res.status(500).json({ type: "error", message: error.message });
    }
    res.json(JSON.parse(body));
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

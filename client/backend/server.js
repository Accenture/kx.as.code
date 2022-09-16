const express = require("express");
const request = require("request");
const fs = require("fs");
const amqp = require("amqplib");

const app = express();
const bodyParser = require("body-parser");
app.use(bodyParser.json());

const PORT = process.env.PORT || 5001;
const dataPath = "../src/data/combined-metadata-files.json";
const rabbitMqUsername = "test";
const rabbitMqPassword = "test";
const rabbitMqHost = "localhost";

app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Credentials", "true");
  res.setHeader("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers"
  );
  next();
  bodyParser.json();
  bodyParser.urlencoded({
    extended: true,
  });
});

app.route("/api/add/application/:queue_name").post((req, res) => {
  connection = amqp.connect(
    "amqp://" + rabbitMqUsername + ":" + rabbitMqPassword + "@" + rabbitMqHost
  );
  console.log("install app req.body: ", req.body);

  connection.then(async (conn) => {
    const channel = await conn.createChannel();
    await channel.assertExchange("action_workflow", "direct", {
      durable: true,
    });
    await channel.assertQueue(req.params.queue_name);
    channel.bindQueue(
      req.params.queue_name,
      "action_workflow",
      req.params.queue_name
    );
    channel.sendToQueue(
      req.params.queue_name,
      Buffer.from(JSON.stringify(req.body))
    );
  });

  res.send("The POST request is being processed to Queue: ");
});

app.route("/api/checkRmqConn").get((req, res) => {
  console.log("checkRmqConn triggered.");
  try {
    request(
      "http://" + rabbitMqHost + ":15672",
      function (err, response, body) {
        console.log("BODY CONN REQ", res.statusCode);
        res.send(response?.statusCode);
      }
    );
  } catch (err) {
    res.send(err);
  }
});

app.route("/api/queues/:queue_name").get((req, res) => {
  try {
    var url =
      "http://" +
      rabbitMqUsername +
      ":" +
      rabbitMqPassword +
      "@" +
      rabbitMqHost +
      ":15672/api/queues/%2F/" +
      req.params.queue_name +
      "/get";

    // console.log("url: ", url);

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
        console.log(error.message);

        return res.status(500).json({ type: "error", message: error.message });
      }
      res.json(JSON.parse(body));
    });
  } catch (error) {
    console.log(error);
  }
});

//move queue endpoint
app.route("/api/move/:from_queue/:to_queue").get((req, res) => {
  console.log("move triggered.");
  var url =
    "http://" +
    rabbitMqUsername +
    ":" +
    rabbitMqPassword +
    "@" +
    rabbitMqHost +
    ":15672/api/parameters/shovel/%2F/Move%20from%20" +
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
    res.send(fil[0]);
  });
});

app.route("/api/consume/:queue_name").get((req, res) => {
  connection = amqp.connect(
    "amqp://" + rabbitMqUsername + ":" + rabbitMqPassword + "@" + rabbitMqHost
  );

  connection.then(async (conn) => {
    const channel = await conn.createChannel();
    await channel.assertExchange("action_workflow", "direct", {
      durable: true,
    });
    await channel.assertQueue(req.params.queue_name);
    channel.bindQueue(
      req.params.queue_name,
      "action_workflow",
      req.params.queue_name
    );
    // channel.consume(req.params.queue_name, (msg) => {
    //   console.log(msg.content.toString());
    //   channel.ack(msg);
    // });

    try {
      let data = await channel.get(req.params.queue_name); // get one msg at a time
      if (data) {
        data.content ? eval("(" + data.content.toString() + ")()") : "";
        channel.ack(data);
      } else {
        //console.log("Empty Queue")
      }
    } catch (error) {
      return Promise.reject(error);
    }
  });

  res.send("The POST request is being processed!");
});

app.listen(PORT, () => console.log(`listening on ${PORT}`));

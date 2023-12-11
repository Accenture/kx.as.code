const express = require("express");
const request = require("request");
const fs = require("fs");
const amqp = require("amqplib");
const cors = require('cors');
const axios = require('axios');

const app = express();
const bodyParser = require("body-parser");
app.use(bodyParser.json());

const PORT = process.env.PORT || 5001;
const dataPath = "../src/data/combined-metadata-files.json";
const healthCheckDataPath = "../src/data/healthcheckdata.json";
const rabbitMqUsername = "test";
const rabbitMqPassword = "test";
const rabbitMqHost = "localhost";

const healthCheckInterval = 10000; // 10 seconds

app.use(cors());

app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Credentials", "true");
  res.setHeader("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers"
  );
  next();
});

let healthCheckData = {};

const performHealthCheck = async () => {
  try {
    // Request to get the array of completed_queue objects
    const completedQueueResponse = await axios.get("http://localhost:8000/mock/api/queues/completed_queue");

    // Parse the payload from each object in the response array
    const appNames = completedQueueResponse.data.map((item) => {
      const payloadObj = JSON.parse(item.payload);
      return payloadObj.name;
    });

    // Perform health check for each appName
    for (const appName of appNames) {
      const healthCheckUrl = `http://localhost:8000/mock/api/${appName}/healthcheck`;

      const response = await axios.get(healthCheckUrl);

      // Check if the response structure is different
      const responseDataArray = Array.isArray(response.data) ? response.data : [response.data];

      // Create the health check data structure if it doesn't exist
      if (!healthCheckData[appName]) {
        healthCheckData[appName] = [];
      }

      // Add the health check status object
      healthCheckData[appName].push({
        timestamp: new Date().toISOString(),
        status: response.status,
      });

      // If the array exceeds the limit, remove the oldest entry
      if (healthCheckData[appName].length > 60) {
        healthCheckData[appName].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        healthCheckData[appName].shift(); // Remove the oldest entry
      }

      console.log("Added health check status for", appName);
    }

    // Save health check data to file
    fs.writeFile(healthCheckDataPath, JSON.stringify(healthCheckData), (err) => {
      if (err) {
        console.error("Error writing health check data:", err);
      }
    });
  } catch (error) {
    console.error("Error performing health check:", error);
  }
}; 


// Schedule health check every 10s
setInterval(performHealthCheck, healthCheckInterval);

app.route("/api/add/application/:queue_name").post(async (req, res) => {
  try {
    const rabbitMqConnectionString = `amqp://${rabbitMqUsername}:${rabbitMqPassword}@${rabbitMqHost}`;
    let connection = await amqp.connect(rabbitMqConnectionString);

    connection = await amqp.connect(rabbitMqConnectionString);
    console.log("install app req.body: ", req.body);

    const channel = await connection.createChannel();
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

    res.send("The POST request is being processed to Queue: ");
  } catch (error) {
    console.error("Error adding application:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.route("/api/checkRmqConn").get((req, res) => {
  console.log("checkRmqConn triggered.");

  try {
    request("http://" + rabbitMqHost + ":15672", function (err, response, body) {
      if (err) {
        console.error("Error checking RMQ connection:", err);
        res.status(500).send("Internal Server Error");
      } else {
        console.log("BODY CONN REQ", response.statusCode);
        res.send(response ? response.statusCode : 500);
      }
    });
  } catch (err) {
    console.error("Error checking RMQ connection:", err);
    res.status(500).send("Internal Server Error");
  }
});

app.route("/api/queues/:queue_name").get(async (req, res) => {
  try {
    const url = `http://${rabbitMqUsername}:${rabbitMqPassword}@${rabbitMqHost}:15672/api/queues/%2F/${req.params.queue_name}/get`;
    const dataString = '{"vhost":"/","name":"' + req.params.queue_name + '","truncate":"50000","ackmode":"ack_requeue_true","encoding":"auto","count":"100"}';

    const axiosOptions = {
      url: url,
      method: "POST",
      auth: {
        username: rabbitMqUsername,
        password: rabbitMqPassword,
      },
      body: dataString,
    };

    const response = await axios(axiosOptions);

    res.json(response.data);
  } catch (error) {
    console.error("Error getting queue:", error);
    res.status(500).json({ type: "error", message: error.message });
  }
});

app.get('/mock/api/queues/:queue_name', async (req, res) => {
  const { queue_name } = req.params;

  try {
    const response = await axios.get(`http://localhost:8000/mock/api/queues/${queue_name}`);

    const responseData = response.data;

    res.json(responseData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.route("/api/move/:from_queue/:to_queue").get((req, res) => {
  console.log("move triggered.");

  const url = `http://${rabbitMqUsername}:${rabbitMqPassword}@${rabbitMqHost}:15672/api/parameters/shovel/%2F/Move%20from%20${req.params.from_queue}`;
  const dataString = '{"component":"shovel","vhost":"/","name":"Move from "' +
    req.params.from_queue +
    ',"value":{"src-uri":"amqp:///%2F","src-queue":"' +
    req.params.from_queue +
    '","src-protocol":"amqp091","src-prefetch-count":1000,"src-delete-after":"queue-length","dest-protocol":"amqp091","dest-uri":"amqp:///%2F","dest-add-forward-headers":false,"ack-mode":"on-confirm","dest-queue":"' +
    req.params.to_queue +
    '","src-consumer-args":{}}}';

  const axiosOptions = {
    url: url,
    method: "PUT",
    body: dataString,
    auth: {
      username: rabbitMqUsername,
      password: rabbitMqPassword,
    },
  };

  axios(axiosOptions)
    .then((response) => {
      res.json(response.data);
    })
    .catch((error) => {
      console.error("Error moving queues:", error);
      res.status(500).json({ type: "error", message: error });
    });
});

app.get("/api/applications", (req, res) => {
  fs.readFile(dataPath, "utf8", (err, data) => {
    if (err) {
      console.error("Error reading applications data:", err);
      res.status(500).send("Internal Server Error");
    } else {
      res.send(JSON.parse(data));
    }
  });
});

app.get("/api/applications/:app_name", (req, res) => {
  fs.readFile(dataPath, "utf8", (err, data) => {
    if (err) {
      console.error("Error reading applications data:", err);
      res.status(500).send("Internal Server Error");
    } else {
      const filteredApps = JSON.parse(data).filter((app) => app.name === req.params.app_name);
      res.send(filteredApps[0]);
    }
  });
});

app.route("/api/consume/:queue_name").get(async (req, res) => {
  try {
    const rabbitMqConnectionString = `amqp://${rabbitMqUsername}:${rabbitMqPassword}@${rabbitMqHost}`;
    let connection = await amqp.connect(rabbitMqConnectionString);

    const channel = await connection.createChannel();
    await channel.assertExchange("action_workflow", "direct", {
      durable: true,
    });
    await channel.assertQueue(req.params.queue_name);
    channel.bindQueue(
      req.params.queue_name,
      "action_workflow",
      req.params.queue_name
    );

    let data = await channel.get(req.params.queue_name);

    if (data) {
      data.content ? eval("(" + data.content.toString() + ")()") : "";
      channel.ack(data);
    } else {
      //console.log("Empty Queue")
    }

    res.send("The POST request is being processed!");
  } catch (error) {
    console.error("Error consuming queue:", error);
    res.status(500).send("Internal Server Error");
  }
});

// API endpoint to access health check data
app.get("/healthcheckdata", (req, res) => {
  fs.readFile(healthCheckDataPath, "utf8", (err, data) => {
    if (err) {
      console.error("Error reading health check data:", err);
      res.status(500).send("Internal Server Error");
    } else {
      const healthCheckData = JSON.parse(data);
      res.json(healthCheckData);
    }
  });
});

app.listen(PORT, () => {
  console.log(`listening on ${PORT}`);
  // Initial health check on server start
  performHealthCheck();
});

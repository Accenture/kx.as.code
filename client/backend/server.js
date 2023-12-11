const express = require("express");
const request = require("request");
const fs = require("fs");
const amqp = require("amqplib");
const cors = require('cors');
const axios = require('axios');
const bodyParser = require("body-parser");

const dataPath = "./src/data/combined-metadata-files.json";
const healthCheckDataPath = "./src/data/healthcheckdata.json";
const profileConfig = "./src/data/profile-config.json"
const rabbitMqUsername = "guest";
const rabbitMqPassword = "guest";
const rabbitMqHost = "localhost";
const rabbitMqPort = "15672";
const PORT = process.env.PORT || 5001;

const app = express();
app.use(bodyParser.json());

const healthCheckInterval = 60000; // 1 minute

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


// Global error handler for uncaught exceptions -> Remove after testing activity
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);

});

async function fetchHttPath(applicationName) {
  const url = `http://localhost:5001/api/applications/${applicationName}`;

  try {
    const response = await axios.get(url);
    const responseData = response.data;

    if (responseData.urls && responseData.urls.length > 0) {
      const httpPaths = responseData.urls.map(url => url.healthchecks.readiness.http_path);
      console.log(`Application has URLs (http_path): ${httpPaths.join(', ')}`);
      return httpPaths;
    } else {
      console.log(`Application has no URLs`);
      return null;
    }

  } catch (error) {
    console.error('Error fetching data:', error.message);
    console.log("App: ", applicationName)
    return null;
  }
}

let healthCheckData = {};


const performHealthCheck = async () => {
  try {
    // Request to get the array of completed_queue objects
    const completedQueueResponse = await axios.get(`http://localhost:5001/api/queues/completed_queue`);

    // Parse the payload from each object in the response array
    const appNames = completedQueueResponse.data.map((item) => {
      const payloadObj = JSON.parse(item.payload);
      return payloadObj.name;
    });

    const rawData = fs.readFileSync(profileConfig);
    const configData = JSON.parse(rawData);
    const environmentPrefix = configData.config.environmentPrefix;
    const baseDomain = configData.config.baseDomain;

    // Perform health check for each appName
    for (const appName of appNames) {

      // Call fetchData to get httpPath
      const httpPath = await fetchHttPath(appName);

      // Skip health check if httpPath is null
      if (httpPath === null) {
        continue;
      }

      // Append httpPath to the healthCheckUrl
      const healthCheckUrl = `http://${appName}.${environmentPrefix}.${baseDomain}${httpPath}`;
      console.log("DEBUG - Healthcheck URL: ", healthCheckUrl)


      const response = await axios.get(healthCheckUrl);

      // Check if the response structure is different
      const responseDataArray = Array.isArray(response.data) ? response.data : [response.data];

      // Create the health check data structure if it doesn't exist
      if (!healthCheckData.data) {
        healthCheckData.data = {};
      }

      // Create the health check data structure if it doesn't exist for the specific app
      if (!healthCheckData.data[appName]) {
        healthCheckData.data[appName] = [];
      }

      // Add the health check status object only if the array has fewer than 100 elements
      if (healthCheckData.data[appName].length < 120) {
        healthCheckData.data[appName].push({
          timestamp: new Date().toISOString(),
          status: response.status,
        });
      } else {
        // If the array exceeds the limit, remove the oldest entry and add the new object
        healthCheckData.data[appName].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        healthCheckData.data[appName].shift(); // Remove the oldest entry
        healthCheckData.data[appName].push({
          timestamp: new Date().toISOString(),
          status: response.status,
        });
      }
    }

    // Save health check data to file
    fs.writeFile(healthCheckDataPath, JSON.stringify(healthCheckData), (err) => {
      if (err) {
        console.error("Error writing health check data:", err);
      }
    });
  } catch (axiosError) {
    // Handle AxiosError 
    if (axios.isAxiosError(axiosError)) {
      console.error("AxiosError during health check:", axiosError.message);
    } else {
      // Other type of errors
      console.error("Error performing health check:", axiosError);
    }
  }
};


// Schedule health check every 60s
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
    request("http://" + rabbitMqHost + ":" + rabbitMqPort, function (err, response, body) {
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
    const url = `http://${rabbitMqHost}:${rabbitMqPort}/api/queues/%2F/${req.params.queue_name}/get`;
    const dataString = '{"count":99999999,"ackmode":"ack_requeue_true","encoding":"auto","truncate":50000}';
    
    const axiosOptions = {
      url: url,
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(`${rabbitMqUsername}:${rabbitMqPassword}`).toString('base64')}`
      },
      data: dataString,
    };

    const response = await axios(axiosOptions);
    res.json(response.data);
  } catch (error) {
    console.error("Error getting queue:", error);
    res.status(500).json({ type: "error", message: error.message });
  }
});

app.route("/api/move/:from_queue/:to_queue").get((req, res) => {
  console.log("move triggered.");

  const url = `http://${rabbitMqUsername}:${rabbitMqPassword}@${rabbitMqHost}:${rabbitMqPort}/api/parameters/shovel/%2F/Move%20from%20${req.params.from_queue}`;
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
    const queueName = req.params.queue_name;
    const url = `http://${rabbitMqHost}:${rabbitMqPort}/api/queues/%2F/${queueName}/get`;
    const dataString = '{"count":1,"ackmode":"ack_requeue_false","encoding":"auto","truncate":50000}';

    const axiosOptions = {
      url: url,
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(`${rabbitMqUsername}:${rabbitMqPassword}`).toString('base64')}`
      },
      data: dataString,
    };
 
    const response = await axios(axiosOptions);

    if (response.data.length > 0) {
      const messageContent = JSON.parse(response.data[0].payload);
      res.json({ type: "success", message: "Message consumed successfully", content: messageContent });
    } else {
      res.json({ type: "info", message: "No messages available in the queue" });
    }
  } catch (error) {
    console.error("Error consuming message from the queue:", error);
    res.status(500).json({ type: "error", message: error.message });
  }
});

// API endpoint to access health check data for Prometheus
app.get("/healthcheckdata-prometheus", (req, res) => {
  fs.readFile(healthCheckDataPath, "utf8", (err, data) => {
    if (err) {
      console.error("Error reading health check data:", err);
    } else {
      const healthCheckData = JSON.parse(data);

      var response = "";
      var resString = "application_status{app=";
      let name = "";
      for (const x in healthCheckData) {
        name = x;
        let mainStatus = healthCheckData[name][healthCheckData[name].length - 1];

        response = response + resString + "\"" + name + "\"" + "}" + " " + mainStatus.status + " " + new Date().getTime() + "\n"

      }
      res.setHeader('Content-Type', register.contentType);
      res.send(response);
    }
  });
});

// API endpoint to access health check data
app.get("/healthcheckdata", (req, res) => {
  fs.readFile(healthCheckDataPath, "utf8", (err, data) => {
    if (err) {
      console.error("Error reading health check data:", err);
      // res.status(500).send("Internal Server Error");
    } else {
      const healthCheckData = JSON.parse(data);
      res.json(healthCheckData.data);
    }
  });
});

app.listen(PORT, () => {
  console.log(`listening on ${PORT}`);
  // Initial health check on server start
  performHealthCheck();
});

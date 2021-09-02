const express = require('express');
const { url } = require('inspector');
const request = require('request');

const app = express();

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  next();
});

app.route('/queues/:queue_name').get((req, res) => {
    turl = "http://test:test@localhost:15672/api/queues/%2f/" + req.params.queue_name;
  request(
    { url: turl },
    (error, response, body) => {
      if (error || response.statusCode !== 200) {
        return res.status(500).json({ type: 'error', message: err.message });
      }

      res.json(JSON.parse(body));
    }
  )
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`listening on ${PORT}`));
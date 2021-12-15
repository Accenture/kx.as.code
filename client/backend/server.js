const express = require('express');
const request = require('request');
const app = express();
const mongoose = require("mongoose")

// mongoose.connect("mongodb://localhost/subscribers", {useNewUrlParser: true })
// const db = mongoose.connection
// db.on("error", (error) => console.error(error))
// db.once("error", (error) => console.error(error))

const PORT = process.env.PORT || 5000;

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
});

app.route('/api/queues/:queue_name').get((req, res) => {

    var url = "http://test:test@localhost:15672/api/queues/%2F/" + req.params.queue_name + "/get";   
    
    var dataString = '{"vhost":"/","name":"' + req.params.queue_name + '","truncate":"50000","ackmode":"ack_requeue_true","encoding":"auto","count":"100"}';

    let options = {
        url: url,
        method: 'POST',
        body: dataString
    };
    
    request( 
       options,
        (error, response, body) => {
            if (error || response.statusCode !== 200) {
                return res.status(500).json({ type: 'error', message: error.message });
            }
            res.json(JSON.parse(body));
        }
    )
});

app.listen(PORT, () => console.log(`listening on ${PORT}`));


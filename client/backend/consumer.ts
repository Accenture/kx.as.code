import * as Amqp from "amqp-ts";

const fetch = require('node-fetch');
const axios = require('axios')

let connection = new Amqp.Connection("amqp://test:test@localhost");

let queue = connection.declareQueue("testing2");

queue.prefetch(500);
queue.activateConsumer(async (message) => {
  const site: string = message.getContent().site;
  console.log(site)
  axios(site).then((response: any) => {
    console.log(response.status);
    message.ack();
  })
}).then(({consumerTag}) => {
  console.log(consumerTag)
});
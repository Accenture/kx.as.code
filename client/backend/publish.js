const rabbit = require("amqplib");
const QUEUE_NAME = "square3";
const EXCHANGE_TYPE = "direct";
const EXCHANGE_NAME = "main";
const KEY = "myKey";
const number = "5";
connection = rabbit.connect("amqp://localhost");
connection.then(async (conn) => {
  const channel = await conn.createChannel();
  await channel.assertExchange(EXCHANGE_NAME, EXCHANGE_TYPE);
  await channel.assertQueue(QUEUE_NAME);
  channel.bindQueue(QUEUE_NAME, EXCHANGE_NAME, KEY);
  channel.sendToQueue(QUEUE_NAME, Buffer.from(number));
});

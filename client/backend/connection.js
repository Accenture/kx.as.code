
var amqp = require('amqplib/callback_api')
module.exports = (callback) => {
  amqp.connect('amqp://localhost',
    (error, conection) => {
    if (error) {
      throw new Error(error);
    }

    callback(conection);
  })
}
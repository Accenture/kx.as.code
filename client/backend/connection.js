var amqp = require('amqplib/callback_api')
module.exports = (callback) => {
  amqp.connect('amqp://test:test@localhost:15672',
    (error, conection) => {
    if (error) {
      throw new Error(error);
    }

    callback(conection);
  })
}
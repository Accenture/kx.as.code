var amqp = require('amqplib/callback_api')
module.exports = (callback) => {
  amqp.connect('amqp://user:user@whateverhost:whateverport',
    (error, conection) => {
    if (error) {
      throw new Error(error);
    }

    callback(conection);
  })
}
var rabbitMQHandler = require('./connection');

module.exports = rabbitMQHandler;

router.route('/calc/sum').post((req, res) => {
  rabbitMQHandler((connection) => {
    connection.createChannel((err, channel) => {
      if (err) {
        throw new Error(err);
      }
      var mainQueue = 'calc_sum'
  
      channel.assertQueue('', {exclusive: true}, (err, queue) => {
        if (err) {
          throw new Error(err)
        }
        channel.bindQueue(queue.queue, mainQueue, '')
        channel.consume(queue.que, (msg) => {
          var result = JSON.stringify({result: Object.values(JSON.parse(msg.content.toString()).task).reduce((accumulator, currentValue) => parseInt(accumulator) + parseInt(currentValue)) });
          calcSocket.emit('calc', result)
        })
      }, {noAck: true})
    })
  })
  })
var express = require('express') 
var bodyParser = require('body-parser')
var rabbitMQHandler = require('connection.js')

var app = express()
var router = express.Router()
var server = require('http').Server(app) 
var socketIO = require('socket.io')(server)

var calcSocket = socketIO.of('/calc')

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

app.use(express.urlencoded({ extended: true }))
app.use('/api', router)
router.route('/calc/sum').post((req, res) => {
    rabbitMQHandler((connection) => {
      connection.createChannel((err, channel) => {
        if (err) {
          throw new Error(err)
        }
        var ex = 'calc_sum'
        var msg = JSON.stringify({task: req.body });

        channel.publish(ex, '', Buffer.from(msg), {persistent: false})

        channel.close(() => {connection.close()})
      })
    })
  })

server.listen(5555, '0.0.0.0',
  () => {
    console.log('Running at at localhost:5555')
  }
)
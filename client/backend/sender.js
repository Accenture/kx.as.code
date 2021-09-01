import amqp from "amqplib"

amqp.connect('amqp://localhost', (connError, connection) => {
    if (connError) {
        throw connError;
    }
    connection.createChannel((channelError, channel) => {
        if (channelError) {
            throw channelError;
        }
        const QUEUE = 'testqueue'
        channel.assertQueue(QUEUE);
        channel.sendToQueue(QUEUE, Buffer.from('hello world!'));
        console.log(`Message send ${QUEUE}`);
    })
})
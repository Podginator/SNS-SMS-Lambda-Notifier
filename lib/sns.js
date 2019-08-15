const AWS = require('aws-sdk');
const sns = new AWS.SNS({});

const convertToSmsMessage = (message) => ({
    Message: message.content,
    PhoneNumber: message.location
});

const publish = (messages) => {
    return Promise.all(messages
        .map(convertToSmsMessage)
        .map(
            smsMessage => sns
            .publish(smsMessage)
            .promise()))
};

module.exports = {
    publish
};

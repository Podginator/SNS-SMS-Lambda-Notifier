const { generateMessage } = require('../generateMessage');
const { getPhoneNumbers, putMessages } = require('../dynamoDb');
const { publish } = require('../sns');
const { extractPostParams } = require('../utils');

const generateSuccessCode = (messageIds) => {
    const body = { messageIds };
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
    };
}

const persistMessages = async (messages) => {
    try {
        await putMessages(messages);
    } catch (e) {
        console.error('Unable to persist ')
        throw e;
    }
}

const publishSms = async (messages) => {
    try {
        await publish(messages);
    } catch (e) {
        console.error('Unable to send SMS', e)
        throw e;
    }
}

const addMessage = async (event) => {
    const { message, phoneNumbers } = extractPostParams(event);
    const numbers = phoneNumbers || await getPhoneNumbers();
    const messages = numbers.map(generateMessage(message));

    await publishSms(messages);
    await persistMessages(messages);

    const messageIds = messages.map(message => message.messageId);
    return generateSuccessCode(messageIds);
};


module.exports = {
    addMessage
};
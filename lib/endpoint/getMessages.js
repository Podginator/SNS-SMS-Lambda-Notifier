const { getMessages: getMessagesDynamo } = require('../dynamoDb');
const { extractGetParams } = require('../utils');


const generateSuccessCode = (messages) => ({
    statusCode: 200,
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(messages)
});

const getMessages = async (event) => {
    const { phoneNumber } = extractGetParams(event)
    const messages = await getMessagesDynamo(phoneNumber);
    return generateSuccessCode(messages);
};

module.exports = {
    getMessages
}
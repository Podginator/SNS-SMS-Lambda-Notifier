const uuid = require('uuid/v4');

const generateMessage = (messageContents) =>  (phoneNumber) => ({ 
    messageId: uuid(),
    content: messageContents,
    location: phoneNumber
});

module.exports = { generateMessage };

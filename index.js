const { getMessages } = require('./lib/endpoint/getMessages');
const { addMessage } =  require('./lib/endpoint/addMessage');

module.exports = {
    addMessage,
    getMessages,
};
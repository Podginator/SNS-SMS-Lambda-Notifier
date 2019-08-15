const AWS = require("aws-sdk");
const _ = require("lodash/fp");

const documentClient = (() => {
  const db = new AWS.DynamoDB({
    endpoint: process.env.DDB_ENDPOINT
  });

  return new AWS.DynamoDB.DocumentClient({
    service: db
  });
})();

const getPhoneNumbers = async () => {
  const params = {
    TableName: process.env.PHONE_DB
  };

  let phoneNumbers = [];
  let items;
  do {
    items = await documentClient.scan(params).promise();
    const numbers = items.Items.map(item => item.phoneNumber);
    phoneNumbers.push(...numbers);
    params.ExclusiveStartKey = items.LastEvaluatedKey;
  } while (typeof items.LastEvaluatedKey != "undefined");

  return phoneNumbers;
};

const getMessages = async phoneNumber =>
  documentClient
    .query({
      TableName: process.env.MESSAGE_DB,
      IndexName: "PhoneNumberIndex",
      KeyConditionExpression: "phoneNumber = :phoneNumber",
      ExpressionAttributeValues: {
        ":phoneNumber": phoneNumber
      }
    })
    .promise()
    .then(response => response.Items)

const convertToDynamoDBFormat = message => {
  return {
    PutRequest: {
      Item: {
        messageId: message.messageId,
        phoneNumber: message.location,
        content: message.content
      }
    }
  };
};

const putMessages = messages => {
  const batchMessages = _.flow(
    _.map(convertToDynamoDBFormat),
    _.chunk(25)
  )(messages);

  return _.map(batch =>
    documentClient
      .batchWrite({
        RequestItems: {
          [process.env.MESSAGE_DB]: batch
        }
      })
      .promise()
  )(batchMessages);
};

module.exports = {
  getPhoneNumbers,
  getMessages,
  putMessages
};

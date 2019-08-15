const _ = require('lodash/fp');

const extractPostParams = event => {
  return JSON.parse(_.get('body')(event) || "{}" );
};

const extractGetParams = event => {
  return { phoneNumber: _.get('pathParameters.proxy')(event) };

};

module.exports = { extractGetParams, extractPostParams };

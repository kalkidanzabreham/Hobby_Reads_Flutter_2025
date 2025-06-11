const dotenv = require("dotenv");
dotenv.config();

const host = process.env.DB_HOST;
const user = process.env.DB_USER;
const password = process.env.DB_PASSWORD;
const database = process.env.DB_NAME;
const waitForConnections = true;
const connectionLimit = 10;
const queueLimit = 0;

console.log(process.env.DB_NAME);

module.exports = {
  host,
  user,
  password,
  database,
  waitForConnections,
  connectionLimit,
  queueLimit
};

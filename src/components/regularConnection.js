'use strict'
// require('./prototypes')
let CONSTANTS = require('./../components/Constants')

let mysql = require('mysql')

let main = mysql.createPool({
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_MAIN,
    host: process.env.DB_HOST,
    charset : 'utf8mb4',
    connectionLimit: CONSTANTS.DEFAULT_CONNECTION_LIMIT,
    acquireTimeout: CONSTANTS.ACQUIRE_TIME_OUT
})

let stage = mysql.createPool({
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_STAGE,
    host: process.env.DB_HOST,
    charset : 'utf8mb4',
    connectionLimit: CONSTANTS.DEFAULT_CONNECTION_LIMIT,
    acquireTimeout: CONSTANTS.ACQUIRE_TIME_OUT
})

let config = mysql.createPool({
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_CONFIG,
    host: process.env.DB_HOST,
    charset : 'utf8mb4',
    connectionLimit: CONSTANTS.DEFAULT_CONNECTION_LIMIT,
    acquireTimeout: CONSTANTS.ACQUIRE_TIME_OUT
})

module.exports = { main, stage, config }
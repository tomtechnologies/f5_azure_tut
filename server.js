var config = require('./config.json');

const mysql = require('mysql');
const sql_con = mysql.createConnection({
	host: config.mysql_host,
	user: config.mysql_user,
	password: config.mysql_password,
	database: config.mysql_crypto_db
});


const express = require('express');
const app = express();


sql_con.connect((err) => {
	if (err) throw err;
	console.log('MySQL Connected!');
});


app.get('/', (req, res) => res.send('Hello World!'))

app.listen(3000, () => console.log('Example app listening on port 3000!'))
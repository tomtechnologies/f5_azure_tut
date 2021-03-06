var config = require('./config.json');
const mysql = require('mysql');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
var myArgs = process.argv.slice(2);

const sql_con = mysql.createConnection({
	host: config.mysql_host,
	user: config.mysql_user,
	password: config.mysql_password,
	database: config.mysql_db
});


var listen_ip = myArgs[0];
var listen_port = myArgs[1];


// Basic listening app
if (listen_port >= 3000 && listen_port < 4000) {
    app.get('/', (req, res) => res.send("Hello World from " + listen_ip + ":" + listen_port));
}

// SQL app
if (listen_port >= 4000 && listen_port < 5000) {
    sql_con.connect((err) => {
        if (err) throw err;
        console.log('MySQL Connected!');
    });

    app.use(bodyParser.json()); // support json encoded bodies
    app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies
    app.get('/', (req, res) => {
        res.send("<html>\n<form action='/login' method='post'>\n<input type='text' name='username'>\n<input type='password' name='password'>\n<button type='submit'>Login</button>\n</form>\n</html>")
    });

    app.post('/login', function(req, res) {
        var username = req.body.username;
        var password = req.body.password;
        // Intentionally vulnerable SQL query.
        var query = "SELECT * FROM user WHERE user = '" + username + "' AND pass = '" + password + "';";

        sql_con.query(query, function(err, result, fields) {
            if (err) {
            res.send(err);
            } else {
                res.send(result);
            }
        });
    });
}



app.listen(listen_port, listen_ip, () => console.log(listen_ip + ":" + listen_port + " Now listening"));
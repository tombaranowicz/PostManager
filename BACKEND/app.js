var express = require('express');
var bodyParser = require("body-parser");
var fs = require("fs");
var Twit = require('twit')
var path = require('path');
var CronJob = require('cron').CronJob;

var mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/social');

var User = require('./models/User');
var userController = require('./controllers/user');
var taskController = require('./controllers/task');
var cron_jobController = require('./controllers/cron_job');
var utilsController = require('./controllers/utils');

var app = express();
app.set('port', 80);
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));
app.use(bodyParser.json({limit: '50mb'}));

app.use(express.static(path.join(__dirname, 'public'), { maxAge: 31557600000 }));
app.use(express.static(path.join(__dirname, 'uploads'), { maxAge: 31557600000 }));

app.post('/api/login_twitter', userController.postLoginTwitter);
app.get('/api/user_accounts', userController.getUserAccounts);
app.post('/api/add_account_twitter', userController.postAddTwitterAccount);

app.post('/api/add_task', taskController.postAddTask);
app.post('/api/post_task', taskController.postPostTask);
app.post('/api/delete_task', taskController.postDeleteTask);
app.get('/api/user_tasks', taskController.getUserTasks);
app.get('/api/account_tasks', taskController.getAccountTasks);

app.get('/api/utils/shortUrl', utilsController.getShortUrl);

app.engine('html', require('ejs').renderFile);
app.set('views', __dirname + '/public/views');
app.set('view engine', 'html');
app.get('/', function(req, res) {
    res.render('index.html');
});

app.listen(app.get('port'), function() {
  console.log('Express server listening on port %d in %s mode', app.get('port'), app.get('env'));
});

module.exports = app;

// CRON PARAMS
// Seconds: 0-59
// Minutes: 0-59
// Hours: 0-23
// Day of Month: 1-31
// Months: 0-11
// Day of Week: 0-6
new CronJob('0 * * * * *', function() {
  cron_jobController.tasks();
}, null, true, null);
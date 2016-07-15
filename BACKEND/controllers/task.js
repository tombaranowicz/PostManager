var mongoose = require('mongoose');
var Twit = require('twit')
var User = require('../models/User');
var Account = require('../models/Account');
var Task = require('../models/Task');

var async = require('async')
var fs = require('fs');
var path = require('path');

// app.post('/api/add_task', taskController.postAddTask);
// params user_token, message, media, date (milliseconds in UTC timezone), account_ids, 
exports.postAddTask = function(req, res) {
	
	console.log("ADD TASK CALLED")
	// console.log('received params ' + JSON.stringify(req.body));
	User.findOne({ 'token': req.body.user_token }, function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		Account.find({'_id': { $in: req.body.account_ids}}, function(err, accounts) {
			if (err) return res.status(500).send('Cannot verify accounts.');

			var task = new Task({
				user: user,
				accounts: accounts,
				message: req.body.message,
				date: new Date(req.body.date)
			});

			if (req.body.hasOwnProperty('media')) { //media in base64 attached
				response = {};
				response.data = new Buffer(req.body.media, 'base64');

				var d = new Date();
		        var n = d.getTime();
		        var imagePath = '/uploads/'+n+'.png';
		        var full_path = '../public' + imagePath;

		        console.log('save path ' + full_path);
		        var newPath = path.join(__dirname, full_path);
		        fs.writeFile(newPath, response.data, function (err) {
					if (err) {
						console.log('error ' + err);
						return res.status(500).send('Invalid media file');
					}

					console.log('save path ' + imagePath);
					task.media_path = imagePath;
					task.save(function(err) {
						if (err) return res.status(500).send(err);
						return res.send({"response": "OK"});
					});
		        });
			} else { //no media in base64 attached
				task.save(function(err) { 
					if (err) return res.status(500).send(err);
					return res.send({"response": "OK"});
				});
			}
		});
	});
}

// app.post('/api/post_task', taskController.postPostTask);
// params user_token, message, media, date (milliseconds in UTC timezone), account_ids, 
exports.postPostTask = function(req, res) {

	console.log("POST TASK CALLED")
	// console.log('received params in post ' + JSON.stringify(req.body));
	User.findOne({ 'token': req.body.user_token }, function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		console.log('received params_1');

		Account.find({'_id': { $in: req.body.account_ids}}, function(err, accounts) {
			if (err) return res.status(500).send('Cannot verify accounts.');

			var task = new Task({
				user: user,
				accounts: accounts,
				message: req.body.message,
				date: new Date(req.body.date)
			});

			console.log('received params_2');

			if (req.body.hasOwnProperty('media')) { //media in base64 attached

				response = {};
				response.data = new Buffer(req.body.media, 'base64');

				var d = new Date();
		        var n = d.getTime();
		        var imagePath = '/uploads/'+n+'.png';
		        var full_path = '../public' + imagePath;

		        console.log('save path ' + full_path);
		        var newPath = path.join(__dirname, full_path);
		        fs.writeFile(newPath, response.data, function (err) {
					if (err) {
						console.log('error ' + err);
						return res.status(500).send('Invalid media file');
					}

					console.log('save path ' + imagePath);
					task.media_path = imagePath;
					task.save(function(err) {
						if (err) return res.status(500).send(err);
						task.sendTask();
						return res.send({"response": "OK"});
					});
		        });
			} else { //no media in base64 attached
				task.save(function(err) { 
					if (err) return res.status(500).send(err);
					task.sendTask();
					return res.send({"response": "OK"});
				});
			}
		});
	});
}

// app.post('/api/delete_task', taskController.postDeleteTask) 
// params token, task_id
exports.postDeleteTask = function(req, res) {
	User.findOne({ 'token': req.body.token }).exec(function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		Task.findOne({ 'user': user, _id:req.body.task_id }).exec(function(err, task) {
			if (err || !task) return res.status(500).send('Task does not exist.');

			//removing media file
			if(task.media_path && task.media_path.length>0) {
				var path = './public' + task.media_path;
				console.log("Going to delete an existing file " + path);
				fs.unlink(path, function(err) {});
			}

			task.remove(function(err) {
				if (err) return res.status(500).send('Internal Error Occurred.');
				
				return res.send({"response": "OK"});
			});
		});
	});
}

// app.get('/api/user_tasks', taskController.getUserTasks);
// params token
// we return only tasks which are in pipeline, able to be removed
exports.getUserTasks = function(req, res) {
console.log("get tasks " + JSON.stringify(req.query));
	User.findOne({ 'token': req.query.token }).exec(function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		Task.find({ 'user': user , 'processed': {$ne: true} }).sort({date: 1}).exec(function(err, tasks) {
			return res.send({'tasks':tasks}); 
		});
	});
}

// app.get('/api/account_tasks', taskController.getAccountTasks);
// params token, account_id
// we return only tasks which are in pipeline, able to be removed
exports.getAccountTasks = function(req, res) {
console.log("get tasks " + JSON.stringify(req.query));
	User.findOne({ 'token': req.query.token }).exec(function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		Task.find({ 'user': user, 'accounts': req.query.account_id, 'processed': {$ne: true} }).sort({date: 1}).exec(function(err, tasks) {
			return res.send({'tasks':tasks}); 
		});
	});
}
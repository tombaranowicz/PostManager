var mongoose = require('mongoose');
var Twit = require('twit')
var User = require('../models/User');
var Account = require('../models/Account');
var Task = require('../models/Task');

var async = require('async')
var fs = require('fs');
var path = require('path');

//CRON JOB FUNCTION
exports.tasks = function() {
	var cutoff = new Date();
	
	// +1 one day
	// cutoff.setDate(cutoff.getDate()+1);

	Task.find({'date': {$lt: cutoff}, 'processed': {$ne: true}}, function(err, tasks) {
		if (!err) {
			for (i=0; i< tasks.length; i++) {
				console.log('Tasks to process ' + tasks.length);
				var task = tasks[i];

				task.processed = true;
				task.save();
				task.sendTask();
			}
		}
	});
}
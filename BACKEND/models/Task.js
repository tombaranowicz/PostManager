var fs = require('fs');
var path = require('path');
var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var Twit = require('twit')
var User = require('./User');
var Account = require('./Account');
var async = require('async')

var taskSchema = new mongoose.Schema({
	
	accounts: [{type : Schema.ObjectId, ref : 'Account'}],
	user: {type : Schema.ObjectId, ref : 'User'},
	message: {type: String},
	media_path: {type: String},
	updatedAt: {type : Date, default : Date.now},
	date: {type : Date},
	processed: {type: Boolean},
})

taskSchema.methods = {

  /**
   * Save product image and upload image
   *
   * @param {Object} images
   * @param {Function} cb
   * @api private
   */

  uploadAndSave: function (media, cb) {

	var self = this
	if (media) {
      fs.readFile(media.path, function (err, data) {

        var d = new Date();
        var n = d.getTime();
        var imagePath = '/uploads/'+n+'.png';
        var full_path = '../public' + imagePath;

        console.log('save path ' + full_path);
        var newPath = path.join(__dirname, full_path);
        fs.writeFile(newPath, data, function (err) {
          if (err) return next(err);

          console.log('save path ' + imagePath);
          self.media_path = imagePath;
          self.save(cb)
        });
      });
    } else {
      console.log("no media");
      self.save(cb)
    }
  },

  sendTask: function() {
  	var self = this

  	console.log("send task called")
  	Account.find({'_id': { $in: self.accounts}}, function(err, accounts) {
		
		// console.log('for ' + accounts.length + ' accounts');
		async.eachSeries(accounts, function iterator(account, callback) {
			console.log("async for account")
		  	if (account.type == 'twitter') {
				var T = new Twit({
					    consumer_key:         'TODO_YOUR_DATA'
					  , consumer_secret:      'TODO_YOUR_DATA'
					  , access_token:         account.token
					  , access_token_secret:  account.secret
				})

				if(self.media_path && self.media_path.length>0) {
					
					var path = './public' + self.media_path;
					var b64content = fs.readFileSync(path, { encoding: 'base64' });

					// first we must post the media to Twitter
					T.post('media/upload', { media_data: b64content }, function (err, data, response) {

					  // now we can reference the media and post a tweet (media will attach to the tweet)
					  var mediaIdStr = data.media_id_string
					  var params = { status: self.message, media_ids: [mediaIdStr] }

					  T.post('statuses/update', params, function (err, data, response) {
					    // console.log(data)
					    callback();
					  })
					})
				} else {
					var params = { status: self.message }
					T.post('statuses/update', params, function (err, data, response) {
						// console.log(data)
						callback();
					})	
				}	
			}
		}, function done() {
		  console.log('done task');
		  	if(self.media_path && self.media_path.length>0) {
				var path = './public' + self.media_path;
				fs.unlink(path, function(err) {});
				console.log("remove file called " + path)
			}
		});
	});
  }
}

module.exports = mongoose.model('Task', taskSchema);
var mongoose = require('mongoose');
var Twit = require('twit')
var User = require('../models/User');
var Account = require('../models/Account');
var randtoken = require('rand-token');

// app.post('/api/login_twitter', userController.postLoginTwitter);
// params secret, token
exports.postLoginTwitter = function(req, res) {
	
	console.log('params ' + JSON.stringify(req.body));
	var token = req.body.token;
	var secret = req.body.secret;

	var T = new Twit({
	    consumer_key:         'TODO_YOUR_DATA'
	  , consumer_secret:      'TODO_YOUR_DATA'
	  , access_token:         token
	  , access_token_secret:  secret
	})

	T.get('account/verify_credentials', {  }, function(err, data, response) {
		if (err) {
			console.log('error 1');
			return res.status(500).send('Cannot verify user.');
		} else {
			User.findOne({ 'username': data.screen_name }, function(err, existingUser) {
				if (!existingUser) { 
					//1. create new user and new account
					//2. assign account to user
					//3. return token

					var account = new Account({
						username: data.screen_name,
						type: 'twitter',
						token: token,
						secret: secret,
						profile_image_url: data.profile_image_url_https,
						info: data
				  	});

				  	account.save(function(err) {
				    	if (err) {
				    		console.log('error 2 ' + err);
				    		return res.status(500).send(err);
				    	}

					    var user = new User({
							username: data.screen_name,
							provider: 'twitter',
							token: randtoken.generate(16),
							accounts: [account]
					  	});

						user.save(function(err) {
					      if (err) {
					      	console.log('error 3 ' + err);
					      	return res.status(500).send(err);
					      }
					      res.send({token: user.token});
					    });
				    });
				} else { 
				//1. return token to user
					return res.send({token: existingUser.token});
				}
			});
		}
	})
}

// app.post('/api/add_account_twitter', userController.postAddTwitterAccount);
// params user_token, secret, token
exports.postAddTwitterAccount = function(req, res) {
	
	User.findOne({ 'token': req.body.user_token }, function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		var token = req.body.token;
		var secret = req.body.secret;

		var T = new Twit({
		    consumer_key:         'TODO_YOUR_DATA'
		  , consumer_secret:      'TODO_YOUR_DATA'
		  , access_token:         token
		  , access_token_secret:  secret
		})

		T.get('account/verify_credentials', {  }, function(err, data, response) {
			if (err) return res.status(500).send('Cannot verify user.');
			
			//SECURITY NOT WORKING PROPER
			Account.findOne({'_id': { $in: user.accounts}, 'token': token, 'secret': secret}, function(err, acc) {
				if (acc) return res.send({"response": "OK"});
				
				var account = new Account({
					username: data.screen_name,
					type: 'twitter',
					token: token,
					secret: secret,
					profile_image_url: data.profile_image_url_https,
					info: data
			  	});

				account.save(function(err) {
			    	if (err) return res.status(500).send(err);

			    	user.accounts.push(account);
					user.save(function(err) {
				      if (err) return res.status(500).send(err);
				      return res.send({"response": "OK"});
				    });
			    });
			});
		});
	});
}

// app.get('/api/user_accounts', userController.getUserAccounts);
// params user_token
exports.getUserAccounts = function(req, res) {
	console.log("get accounts " + JSON.stringify(req.query));
	//TODO REMOVE ACCOUNTS WITH THE SAME USERNAME
	User.findOne({ 'token': req.query.token }).populate('accounts').exec(function(err, user) {
		if (!user) {
			return res.status(401).send('Cannot verify user.');
		} else if (err) {
			return res.status(500).send(err);
		}

		return res.send({'accounts':user.accounts}); 
	});
}
var mongoose = require('mongoose');
var Schema = mongoose.Schema

var userSchema = new mongoose.Schema({
	username: { type: String},
	provider: { type: String},
	token: { type: String},
	// accounts: [mongoose.Schema.Types.Mixed],
	accounts: [{type : Schema.ObjectId, ref : 'Account'}],
	updatedAt: {type : Date, default : Date.now}
})

module.exports = mongoose.model('User', userSchema);
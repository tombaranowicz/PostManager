var mongoose = require('mongoose');

var accountSchema = new mongoose.Schema({
	username: { type: String},
	type: { type: String},
	secret: { type: String},
	token: { type: String},
	profile_image_url: { type: String},
	info: mongoose.Schema.Types.Mixed,
	updatedAt: {type : Date, default : Date.now}
})

module.exports = mongoose.model('Account', accountSchema);
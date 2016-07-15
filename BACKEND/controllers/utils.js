var googl = require('goo.gl');
googl.setKey('TODO_YOUR_DATA');
googl.getKey();

// app.get('/api/utils/shortUrl', utilsController.getShortUrl);
// params url
// we return only tasks which are in pipeline, able to be removed
exports.getShortUrl = function(req, res) {
	googl.shorten(req.query.url)
    .then(function (shortUrl) {
        console.log(shortUrl);
        return res.send({'short_url':shortUrl, 'url':req.query.url}); 
    })
    .catch(function (err) {
        console.error(err.message);
        return res.status(500).send(err);
    });
}
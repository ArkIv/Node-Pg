var pg = require('../bin');

pg.init(1, {
	'user': 'relive',
	'dbname': 'relive',
	'hostaddr': process.argv[2],
	'password': 'fyfvdcthfd5',
	'port': 6432
});

var count = parseInt(process.argv[3]);
var query = process.argv[4]  || "SELECT 1";

var r = 0;
var e = 0;

var mem = 0;

function exec() {
	pg.exec(query, callback);
}

function callback(err, res) {
	exec();

	if (err !== null) {
		e++;
	}

	mem += process.memoryUsage().heapUsed/1024/1024;

	r++;
	if (r === count) {
		console.log('[NODE-PG] | R:', r, ' | E:', e, ' | T:', Date.now() - t, ' | M:', (Math.round(mem/r*10)/10));
		process.exit();
	}

	//console.log(r, ':', pg.getSize());
}


var t = Date.now();
var i = 0;
while (i < count) {

	setTimeout(function() {
		exec();
	}, 100 * Math.sqrt(i));

	i++;
}



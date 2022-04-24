package laerm;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;

typedef Theme = {
	var bg:String;
	var fg:String;
	var acc:String;
}

inline var URL = 'https://rrr.disktree.net:8443';
inline var BORDER_WIDTH = 8;
var theme(default, null):Theme;

function main() {
	console.info('%c⸸ LAUTER RADIO ⸸', 'background:#fff000;color:#050505;padding:4px;font-size:23px;');

	window.addEventListener('load', e -> {
		var style = window.getComputedStyle(document.documentElement);
		theme = {
			bg: style.getPropertyValue('--bg'),
			fg: style.getPropertyValue('--fg'),
			acc: style.getPropertyValue('--acc'),
		};

		var radio = new Radio(URL);
		radio.fetchStatus().then(stats -> {
			trace(stats);
		}).catchError(e -> {
			trace(e);
		});

		// ...............

		////var url = 'http://rrr.disktree.net:8000';
		// var url = 'https://rrr.disktree.net:8443';
		// var radio = new Radio( url );
		// radio.fetchStatus().then( stats -> {
		//// trace(stats);
		// }).catchError( e -> {
		// trace(e);
		// });

		// var body = document.body;
		// var headerElement = body.querySelector('header');
		// var mainElement = body.querySelector('main');
		// var footerElement = body.querySelector('footer');

		// var semver = document.createDivElement();
		// semver.id = "semver";
		// semver.classList.add( 'meta' );
		// semver.textContent = 'v'+Build.getSemver();
		// headerElement.append( semver );

		// headerElement.onclick = function(){
		// radio.togglePlay();
		// }
	}, false);
}

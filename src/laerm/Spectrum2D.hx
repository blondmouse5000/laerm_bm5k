package laerm;

import js.lib.Uint8Array;
import js.html.CanvasRenderingContext2D;
import laerm.App.BORDER_WIDTH;

class Spectrum2D extends Spectrum {
	var graphics:CanvasRenderingContext2D;

	public function new(radio:Radio) {
		super(radio);
		graphics = radio.canvas.getContext("2d");
	}

	public function render(timeData:Uint8Array) {
		var canvas = radio.canvas;
		var frequencyBinCount = radio.analyser.frequencyBinCount;
		var v:Float, x:Float, y:Float;
		var hw = canvas.width / 2, hh = canvas.height / 2;

		var colorBg = (color_bg != null) ? color_bg : App.theme.bg;
		var colorFg = (color_fg != null) ? color_fg : App.theme.fg;

		graphics.clearRect(0, 0, canvas.width, canvas.height);

		// graphics.fillStyle = App.theme.b_med;
		graphics.fillStyle = colorBg;
		graphics.strokeStyle = colorFg; // App.theme.f_med;
		graphics.lineWidth = Std.int((radio.volume.volume * 1000));

		graphics.fillRect(0, 0, canvas.width, canvas.height);
		// drawTime1( 0, 0, canvas.width, canvas.height );

		graphics.lineWidth = Std.int((radio.volume.volume * 1000));
		// var c = Std.int(100-radio.volume.rms*255);
		// graphics.strokeStyle = 'rgba($c,$c,0,1.0)';
		graphics.beginPath();
		for (i in 0...radio.analyser.fftSize) {
			v = i * (Math.PI / 2) / 180;
			x = Math.cos(v) * (100 + timeData[i] * (radio.volume.volume * 2));
			y = Math.sin(v) * (100 + timeData[i] * (radio.volume.volume * 2));
			graphics.lineTo(hw + x, hh + y);
		}
		graphics.stroke();

		var w = 32;
		var h = 32;
		var px = BORDER_WIDTH; // canvas.width - (w+BORDER_WIDTH);
		var py = BORDER_WIDTH; // canvas.height - (h+BORDER_WIDTH);
		// graphics.fillStyle = App.theme.b_med;
		graphics.fillStyle = colorBg;
		// graphics.strokeStyle = App.theme.f_med;
		graphics.strokeStyle = colorFg;
		graphics.lineWidth = 1;
		graphics.fillRect(px, py, w, h);
		graphics.rect(px, py, w, h);
		graphics.stroke();
		drawTime1(px, py, w, h);
	}

	function drawTime1(x:Int, y:Int, w:Int, h:Int) {
		var sliceWidth = w * 1.0 / radio.analyser.frequencyBinCount;
		var cy = h / 2;
		var px = 0.0, py = 0.0;
		graphics.beginPath();
		for (i in 0...radio.analyser.frequencyBinCount) {
			var v = radio.timeData[i] / 128.0;
			py = v * cy;
			if (i == 0) {
				graphics.moveTo(px + x, py + y);
			} else {
				graphics.lineTo(px + x, py + y);
			}
			px += sliceWidth;
		}
		// graphics.lineTo( w, centerY);
		graphics.stroke();
	}
}


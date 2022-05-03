"use strict";

const HOST = 'https://rrr.disktree.net:8443';
const PI2 = Math.PI / 2;

function fetchStatus() {
    return window.fetch(HOST + "/status-json.xsl").then(r => {
        return r.json().then(json => {
            return json.icestats;
        });
    });
}

let toggle;
let canvas;
let graphics;
let audio;
let analyser;
let freqData, timeData, floatData;
let animationFrameId;

function onAnimationFrame(time) {

    animationFrameId = window.requestAnimationFrame(onAnimationFrame);

    analyser.getByteTimeDomainData(timeData);
    analyser.getByteFrequencyData(freqData);
    analyser.getFloatTimeDomainData(floatData);

    let sumOfSquares = 0;
    for (let i = 0; i < floatData.length; i++) {
        sumOfSquares += floatData[i] ** 2;
    }
    //const avgPowerDecibels = 10 * Math.log10(sumOfSquares / floatData.length);
    //console.log(avgPowerDecibels);
    const RMS = Math.sqrt(sumOfSquares / floatData.length);

    //let frequencyBinCount = analyser.frequencyBinCount;
    let hw = canvas.width / 2, hh = canvas.height / 2;
    let v, x, y;
    graphics.clearRect(0, 0, canvas.width, canvas.height);
    graphics.fillStyle = "#fff000";
    graphics.strokeStyle = "#000000";
    graphics.lineWidth = RMS * 1000 * (canvas.width / 1000);
    graphics.beginPath();
    for (let i = 0; i < analyser.fftSize; i++) {
        v = i * PI2 / 180;
        x = Math.cos(v) * (0 + timeData[i] * (RMS * 2));
        y = Math.sin(v) * (0 + timeData[i] * (RMS * 2));
        graphics.lineTo(hw + x, hh + y);
    }
    graphics.stroke();
}

function playStream(source) {

    audio = document.createElement('audio');
    audio.preload = "none";
    audio.crossOrigin = "anonymous";
    audio.controls = false;
    audio.onplaying = e => {

        let audioContext = new AudioContext();

        //gain = audioContext.createGain();
        //gain.connect( audioContext.destination );

        analyser = audioContext.createAnalyser();
        analyser.fftSize = 2048;
        //analyser.smoothingTimeConstant = 0.8;
        //analyser.minDecibels = -140;
        //analyser.maxDecibels = 0;
        analyser.connect(audioContext.destination);
        //analyser.connect( gain );

        freqData = new Uint8Array(analyser.frequencyBinCount);
        timeData = new Uint8Array(analyser.frequencyBinCount);
        floatData = new Float32Array(analyser.fftSize);

        let media = audioContext.createMediaElementSource(audio);
        media.connect(analyser);

        animationFrameId = window.requestAnimationFrame(onAnimationFrame);

        toggle.style.display = 'none';
        toggle.textContent = 'LÄERM';
    }

    var sourceElement = document.createElement('source');
    sourceElement.type = source.server_type;
    //sourceElement.src = source.listenurl;
    sourceElement.src = HOST + '/' + source.server_name;
    audio.append(sourceElement);

    audio.play();

    toggle.textContent = '///';
    toggle.style.pointerEvents = 'none';
}

function stopStream() {
    if (audio) {
        audio.pause();
        audio.onpause = e => {
            audio = null;
        }
        graphics.clearRect(0, 0, canvas.width, canvas.height);
        if (animationFrameId) {
            window.cancelAnimationFrame(animationFrameId);
            animationFrameId = null;
        }
    }
    toggle.style.display = 'block';
    toggle.style.pointerEvents = null;
}

function fitCanvas() {
    if (canvas) {
        let container = document.body.querySelector("main");
        let r = container.getBoundingClientRect();
        canvas.width = r.width;
        canvas.height = r.height;
    }
}

window.onload = e => {

    toggle = document.body.querySelector('main > .toggle');
    canvas = document.body.querySelector('main > canvas.spectrum');
    graphics = canvas.getContext("2d");
    fitCanvas();

    window.onresize = _ => {
        fitCanvas();
    }

    fetchStatus().then(status => {

        console.log(status);

        let source;
        for (let i = 0; i < status.source.length; i++) {
            var src = status.source[i];
            if (src.server_name === 'laerm') {
                source = src;
                break;
            }
        }
        console.log(source);

        canvas.onclick = e => {
            if (audio) {
                stopStream();
            } else {
                if (source) {
                    playStream(source);
                }
            }
        }
    });
}

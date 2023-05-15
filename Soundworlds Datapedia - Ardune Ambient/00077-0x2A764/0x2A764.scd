// 0x2A764 | Deadlands Forest Shrine
/*The truth of culture is that it spreads and evolves freely.
Released into the Public Domain / CC0. Free to access, study, remix and reuse.
Attribution is appreciated, but not required.*/

s.boot;
s.makeGui(w);

// SETUP ///////////////////////////////////////////
(
// Clock
~tempo = 168;
~bar = 60/~tempo;
~beat = ~bar/4;
TempoClock.default.tempo = ~tempo / 60;


// INSTRUMENTS /////////////////////////////////////
SynthDef(\bass, {| midinote = 60 |
	var audio, freq;

	//Convert Midi Note to Freq
	freq = midinote.midicps;

	//Generator
	audio = SinOsc.ar(freq);

	//Envelope
	audio = audio * EnvGen.ar(Env.perc(0.01,1.5,level: 1,curve: -4.0),doneAction: 2);

	//Amp
	audio = audio * \amp.kr(-6.dbamp);

	//Pan
	audio = Pan2.ar(audio, \pan.kr(0));

	//Out
	Out.ar(\out.kr(0),audio);

}
).add;

SynthDef(\highSine,{| midinote = 60, delayTime = 1, delayAmp = 0.7 |
	var audio, trans, freq;

	//Convert Midi Note to Freq
	freq = midinote.midicps;

	//Generator
	audio = SinOsc.ar(freq);

	//Transient
	trans = Pulse.ar(freq * 3) * Env.perc(0.01,0.3,0.1,-7.0).ar;

	//Stack
	audio = audio + trans;

	//Envelope
	audio = audio * EnvGen.ar(Env.perc(0.01,1.5,level: 1,curve: -8.0),doneAction: 2);

	//Modulated LPF
	audio = LPF.ar(audio, (freq * 10 + (SinOsc.ar(0.05,0,0.5,0.5) * 500)));

	//Delay
	audio = audio + AllpassC.ar(audio,
		maxdelaytime: ~bar*4,
		delaytime: ~beat*2,
		decaytime: ~bar*4,
		mul: delayAmp,
		add: 0.0
	);

	//FreeSelf Envelope
	EnvGen.ar(Env.perc(0.01,2.5,level: 1,curve: -8.0),doneAction: 2);

	//Amp
	audio = audio * \amp.kr(-6.dbamp);

	//Pan
	audio = Pan2.ar(audio, \pan.kr(0));

	//Out
	Out.ar(\out.kr(0),audio);
}
).add;

SynthDef(\pad,{| midinote = 60, gate = 1 |
	var audio, freq;

	//Convert Midi Note to Freq
	freq = midinote.midicps;

	//Generator
	audio = Pulse.ar(freq + [-6,-2,0,2,6],[0.8, 0.6, 0.2, 0.6, 0.8]);
	audio = audio + (SinOsc.ar((freq * 1.5) + [-6,-2,0,2,6]) * 0.2);

	//Envelope
	audio = audio * EnvGen.ar(Env.adsr(
			attackTime: 4.0,
			decayTime: 1.0,
			sustainLevel: 1.0,
			releaseTime: 8.0,
			peakLevel: 1.0,
			curve: -4.0,
			bias: 0.0),
	    gate: gate,
	doneAction: 2
	);



	//Spread
	audio = Splay.ar(audio,
		spread: 1,
		level: -20.dbamp,
		center: 0.0,
		levelComp: true
	);

	//Modulated LPF
	audio = LPF.ar(audio, (600 + (SinOsc.ar(0.025,0.5) * 400)));

	//Out
	Out.ar(\out.kr(0),audio);
}
).add;

)

Synth(\highSine);

Synth(\pad);

// PARTS ///////////////////////////////////////////
(
//Set up the Scale
~rootNote = 57;
~noteScale = (~rootNote + [0, 2, 5, 7, 10, 12]);

~partLength = 8;

// Main melody
~keys_notes_seq_array = [
	0, 1, 2, 3,    0, 1, 2, 4,
	2, 3, 2, 3,    2, 3, 4, 1,
	[0,3], 1, 2,   3, 0, 1, [0,3], 4,
	5, 3, 2, 3,    5, 3, 4, 1,

	[2,4], 1, 2,   3, [3,5], 1, 2, 4,
	2, 3, 2, 3,    2, 3, 4, 1,
	[0,3], 1, 2,   3, 0, 1, [0,3], 4,
	5, 3, 2, 3,    5, 3, 4, 1,
];

~keys_notes_seq = Array.fill(~keys_notes_seq_array.size, { arg i;
	~noteScale[~keys_notes_seq_array[i]];
});

//Keys - Duration
~keys_dur = [
	1,2,
	1,2,
	1,2,0.5,0.5,0.5,0.5,
	1,2,
	1,2,
	1,1,1,1,
	1,0.5,0.5,0.5,0.5,
];

~bass_notes_seq = Pseq([~noteScale[0],~noteScale[1],~noteScale[2],~noteScale[3]]-12,inf);

~pad_notes_seq = Pseq([
	[~noteScale[0],~noteScale[3]],
	[~noteScale[2],~noteScale[4]]
],inf);


//Print Streams
~pad_notes_seq_print = ~pad_notes_seq.asStream;
~key_notes_seq_print = Pseq(~keys_notes_seq,inf).asStream;
~bass_notes_seq_print = ~bass_notes_seq.asStream;

//Naming the Part Pdefs
Pdef(\piano1, Pbind(
	\instrument, \highSine,
	\midinote, Pseq(~keys_notes_seq,inf),
	\dur, Pseq(~keys_dur,inf),
	\pan, Pwhite(-0.8, 0.8,inf),
	\delayAmp, Pwrand([0,0.5,0.7],[8,2,1].normalizeSum,inf),
	\func, Pfunc({

		//Print to Window
		"x94: < ".post;
		x = ~key_notes_seq_print.next;

		//Midinote as Hex
		if(x.isKindOf(Array),
			{(x[0].asHexString).post;
				" ".post;
				x[1].asHexString.post;
			},{
				x.asHexString.post;
			}
		);

		" >".postln;

	}),
	)
);


Pdef(\bass, Pbind(
	\instrument, \bass,
	\midinote, ~bass_notes_seq,
	\dur, Pseq([2.5, 1.5] * 2,2),
	\func, Pfunc({

		//Print to Window
		"B200: < ".post;
		x = ~pad_notes_seq_print.next;

		//Midinote as Hex
		if(x.isKindOf(Array),
			{(x[0].asHexString).post;
				" ".post;
				x[1].asHexString.post;
			},{
				x.asHexString.post;
			}
		);

		" >".postln;



	}),

    )
);

Pdef(\pad, Pbind(
	\instrument, \pad,
	\midinote, ~pad_notes_seq,
	\dur, 32,
	\sustain, 4,
	\func, Pfunc({

		//Print to Window
		"R5401: < ".post;
		x = ~pad_notes_seq_print.next;

		//Midinote as Hex
		if(x.isKindOf(Array),
			{(x[0].asHexString).post;
				" ".post;
				x[1].asHexString.post;
			},{
				x.asHexString.post;
			}
		);

		" >".postln;



	}),
    )
);

Pdef(\empty, Pbind(
	\instrument, \default,
	\midinote, Pseq([Rest(~partLength)],1),
	\dur, Pseq([Rest(~partLength)],1),
)
);

)
// COMPOSITION /////////////////////////////////////
(
~composition_piano = Psym(Pseq(#[
	\piano1,
],inf));

~composition_bass = Psym(Pseq(#[

	\empty,
	\empty,

	\bass,
	\bass,
	\bass,
	\bass,
	\bass,
	\bass,
	\bass,
	\bass,
],inf));

~composition_pad = Psym(Pseq(#[
	\pad,
],inf));

~composition_sine_pedal = Pbind(
	\instrument, \bass,
	\midinote, (~rootNote + 3),
	\dur, 8,
	\sustain, 2,
);

)

// PLAY ////////////////////////////////////////////
(
~composition = Ppar([
	~composition_piano,
	~composition_bass,
	~composition_pad,
	~composition_sine_pedal
]).play;
)


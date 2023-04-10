//0x2A763-ii

// SETUP /////////////////////////////////////
//s.options.device_("ASIO : ASIO4ALL v2");
s.boot;


(
//Clock
~tempo = 124;
~dBeat = 60 / ~tempo;

//Setup Groups

~fxGroup = Group.new;
~sndGroup = Group.new(s,\addToHead);

//Setup Busses
s.newBusAllocators; // clear the current busses
~fxBus = Bus.audio(s, 2);


// SYNTHDEFS //////////////////////////////////////////////
//Tuned
SynthDef(\sine1, {arg freq = 440, release = 2.0;
	var snd, snd2, env, tran;

	//Pulse synth with some FM
	snd = SinOsc.ar(freq + ((SinOsc.ar(\fmFreq.kr(400))) *
		(Line.ar(\fmDepth.kr(100),0,release-0.05)))); //Generator


	//additional sine
	snd = snd + SinOsc.ar(freq*3,mul:0.3);

	//additional saw and white noise transient
	tran = (Saw.ar(XLine.ar(freq * 8, freq*2, 0.25),mul:1)* Env.perc(0.001,0.25, curve: - 8).ar());
	tran = tran + (WhiteNoise.ar()*Env.perc(0.001,0.15, curve: - 8).ar());
	snd = snd + (tran * \tranAmp.kr(0.7));

	//additional Klank
	snd = snd + HPF.ar(((Klank.ar(`[
		[freq, freq*2, freq * 3, freq * 8],[1,0.8,0.7,0.25], [2,1,0.7,0.3]
	],Impulse.ar(freq)))* 0.025),1000);

	//Breathier with Extra White Noise
	snd = snd + LPF.ar(HPF.ar(( WhiteNoise.ar() * 0.125),800),14000);

	//Envelope
	env = EnvGen.ar(Env.linen(\attack.kr(0.01),\sustain.kr(0.2),release, curve: \curve.kr(-4)),doneAction: 0);

	//Folding
	//snd2 = Wrap.ar(snd, -0.4, 0.8); //Second signal path to crossfade between
	snd2 = snd;
	snd2 = snd2 * -10.dbamp;

	snd = SelectX.ar(\wrapOn.kr(0.3),[snd.tanh,snd2]); //Crossfade between sine and waveshaped version

	snd = snd * env;
	snd = snd * \amp.kr(-25.dbamp); //Volume

	//LPF
	snd = LPF.ar(snd, \lpfFreq.kr(16000));


	//Delay
	snd = snd + (\delayChance.kr(0) * AllpassC.ar(snd, ~dBeat * 0.75 , ~dBeat * 0.75 , ~dBeat * 16 ) * 1.4).tanh;
	EnvGen.ar(Env.perc(0.01,~dBeat * 16),doneAction: 2); //Destroy the synth

	//Panning
	snd = Pan2.ar(snd, \pan.kr(0)); //Pan

	Out.ar(\outDry.ir(0), snd * \dryLvl.kr(1)); //Out
	Out.ar(\outFX.ir(0), snd * \wetLvl.kr(1)); //FX Out

    }
).add;

//Percussion
SynthDef(\kick, {
	var snd;

	//snd = SinOsc.ar(60 * (1 + (10 * Env.perc(0.001, 0.3, curve: -22.0).ar)) * (1 + (8 * Env.perc(0.0001, 0.001).ar)));
	snd = SinOsc.ar(60 * (1 + (10 * Env.perc(0.001, 0.3, curve: -22.0).ar)));
	snd = snd + (SinOsc.ar(XLine.ar(8000, 50, 0.002)) * 0.8); //Attack Sine
	snd = snd + ((WhiteNoise.ar() * Env.perc(0.001,0.001,curve: -8).ar) * \transient.kr(0.6));//White Noise transient

	snd = (snd * 3.8 + 0.4).tanh; //Overdrive the volume and then waveshape with tanh

	snd = snd * Env.perc(0.001, 0.25 * \lengthMult.kr(1)).ar(Done.freeSelf);

	snd = snd * -10.dbamp;

	//Amp Modifier
	snd = snd * \amp.kr(1);

	snd = Pan2.ar(snd, \pan.kr(0));

	Out.ar(\out.ir(0),snd);

    }
).add;

//Percussion
SynthDef(\kick2, {
	var snd;

	snd = SinOsc.ar(60 * (1 + (10 * Env.perc(0.001, 0.3, curve: -22.0).ar)) * [0.6, 1, 2.2, 3.2]); //Multiple sines
	snd = snd * [0.8, 1, 0.6, 0.4]; // Volumes for sines
	snd = snd * Env.perc(0,[0.08, 0.3, 0.01, 0.005]).ar; //envelopes for sines

	snd = snd.sum;

	snd = snd + (SinOsc.ar(XLine.ar(8000, 50, 0.002)) * 0.8); //Attack Sine
	snd = snd + ((WhiteNoise.ar() * Env.perc(0.001,0.35,curve: -6).ar) * \transient.kr(0.18));//White Noise transient (made longer)

	snd = (snd * 6 + 0.4).tanh; //Overdrive the volume and then waveshape with tanh

	snd = snd * Env.perc(0.001, 0.55 * \lengthMult.kr(1)).ar(Done.freeSelf);
	snd = snd * -10.dbamp;

	//Amp Modifier
	snd = snd * \amp.kr(1);

	snd = Pan2.ar(snd);

	Out.ar(\out.ir(0),snd);

    }
).add;


SynthDef(\snare, {
	var snd;

	//Main Body
	snd = SinOsc.ar(200 * (1 + (0.3 * Env.perc(0.001, 0.06, curve: -4).ar)) * [1, 1.2, 2, 2.8]);
	snd = snd * Env.perc(0, [2,1,0.7,0.25]).ar;
	snd = snd * ([0, -8, -4, -8]-14).dbamp;
	snd = snd.sum;

	//White Noise
	snd = snd + ((WhiteNoise.ar() * Env.perc(0.001,0.25,curve: -4).ar) * \transient.kr(-3.dbamp));

	//Envelope
	snd = snd * Env.perc(0.001, 0.25 * \lengthMult.kr(1), curve: -8).ar(Done.freeSelf);

	//Waveshaping
	snd = (snd * 32).tanh;

	//Final Levels
	snd = snd * -14.dbamp;
	//Amp Modifier
	snd = snd * \amp.kr(1);

	snd = Pan2.ar(snd);

	Out.ar(\out.ir(0),snd);

    }
).add;

//Hat
SynthDef(\hat,{
	var snd;

	//Generator
	snd = WhiteNoise.ar();

	//Envelopes
	snd = snd * Env.perc([0.001, 0.01],0.07 * \lengthMult.kr(1),curve:-8).ar;
	snd = snd.sum;

	//WaveShape
	snd = (snd * 15).tanh;

	//Amplitude
	snd = snd * -25.dbamp;

	//Amp Modifier
	snd = snd * \amp.kr(1);

	//Panning
	snd = Pan2.ar(snd,\hatPan.kr(0));

	//Out
	Out.ar(\out.ir(0),snd);

    }
).add;

//Glitch 1
SynthDef(\glitch1, {
	var snd, sequence, duration;

	duration = \seqDur.kr(0.12);
	sequence = 500 * [\seqInt1.kr(0.6), \seqInt2.kr(1.3), \seqInt3.kr(1.8), \seqInt4.kr(1.3)];

	//Generator
	//Cycles through all the frequencies over the duration time
	snd = SinOsc.ar(Demand.ar(Impulse.ar(sequence.size / duration), 0, Dseq(sequence)));

	//Envelope
	snd = snd * Env.perc(0.001, 0.06, curve: -6).ar();

	//Waveshape
	snd = (snd * 25).tanh;

	//Delay
	snd = snd + (AllpassC.ar(snd, ~dBeat * 0.75 , ~dBeat * 0.75 , ~dBeat * 16 ) * 1.4).tanh;
	EnvGen.ar(Env.perc(0.01,~dBeat * 16),doneAction: 2); //Destroy the synth*/

	//Amp
	snd = snd * -28.dbamp;

	//Stereo
	snd = Pan2.ar(snd, \glitchPan.kr(0));

	Out.ar(\out.kr(~fxBus), snd);

    }
).add;

//Glitch 2
SynthDef(\glitch2, {
	var snd, sequence, duration, tran, freq = 440;

	duration = \seqDur.kr(0.12);
	sequence = 400 * [\seqInt1.kr(0.6), \seqInt2.kr(1.3), \seqInt3.kr(1.8), \seqInt4.kr(2.3)];

	//Generator
	//Cycles through all the frequencies over the duration time
	snd = Saw.ar(Demand.ar(Impulse.ar(sequence.size / duration), 0, Dseq(sequence)));

	//additional saw and white noise transient
	tran = (Saw.ar(XLine.ar(freq * 8, freq*2, 0.25),mul:1)* Env.perc(0.001,0.25, curve: - 8).ar());
	tran = tran + (WhiteNoise.ar()*Env.perc(0.001,0.15, curve: - 8).ar());
	snd = snd + (tran * \tranAmp.kr(0.7));


	//Envelope
	snd = snd * Env.perc(0.001, 0.03, curve: -6).ar(Done.freeSelf);

	//Waveshape
	snd = (snd * 25).tanh;

	//Amp
	snd = snd * -23.dbamp;

	//Stereo
	snd = Pan2.ar(snd, \glitchPan.kr(0));

	Out.ar(\out.kr(0), snd);

    }
).add;

//SynthDef Effects
SynthDef(\fxOne, {
	var snd;

	snd = In.ar(\in.kr(0), 2); //Input

	//Effect
	snd = FreeVerb2.ar(snd[0], snd[1], \mix.kr(0.5), \room.kr(0.9), \damp.kr(0.5));

	Out.ar(\out.kr(0),snd); //Output
    }
).add;



//Add Effects to Bus

//~fxOne.free;
~fxOne = Synth(\fxOne, [\in, ~fxBus], ~fxGroup);
)
)


// COMPOSITION ///////////////////////////////////////
(
//Vars
// var cycles = inf;
var noteList = ([58,61,63,65,66,69,70,72,73,75,77]-12);
var instMap, tempo, dBeat, rest, pattern, notePattern, notePattern2; //Sequencer
var s;
var cycles = 3;

//Server Binding
s = Server.default;

rest = ~dBeat / 4;

//Instrument Dict
instMap = Dictionary[
	$p -> \sine1,
	$c -> \kick,
	$k -> \kick2,
	$s -> \snare,
	$h -> \hat,
	$g -> \glitch1,
	$x -> \glitch2,
	$? -> [\kick, \kick2, \snare, \hat].choose,
];

//Set up the patterns
pattern = "
k...g.k.
..k.s.h.
k.h...h.
h.x.s.hs

k...hhkh
..khs.h.
k.h.kkh.
h.x.s.hs

k..k..kh
.k..k.h.
k.h...h.
h.x.s.hs

k...x.k.
...xsxhx
k.h.hhhs
h.s...s.

k?k?s???
k???s???
??k?s???
k???s???

k.k.s.hk
hhk.shk.
kkhkshks
hhkksxkh

hhk.s.hk
hhkxshkx
kkg.shks
hhkksxkh

kcxcscxc
kcxc.cxc
kcccscxx
cckcscxc

k...x.k.
..k.s.h.
k.h...h.
h.x.s.hs

k...hhkh
..khs.h.
k.h.kkh.
h.x.s.hs

khkhshhk
hhkxhhss
kkhkshks
kksksxkh

khhh?hsh
k...s.?.
..kh?hsh
k.x.s.k.

khskhskh
skh.xhsk
hxkhskss
hxkhskhk

k...s.??
..k.s.??
k...s.??
..k.s.?s

k?k?s???
k???s???
??k?s???
k???s???

k.k.s.hk
hhk.shg.
kkhkshks
hhkksxkh

hhk.s.hk
hhkxshxx
kkh.shks
hhkksxkh

kcxcscxc
kcxc.cxc
kcccscgx
cckcscxc

khkhshhk
hhkxhhss
kkhkshks
kksksxkh

khhh?hsh
k...s.?.
..kh?hsh
k.?.s.k.

..x...x.
..x.hhx.
..x...hh
x...cccc

k.x...x.
..g.....
........
....cccc
";

//Using Scale Degrees
notePattern = Pseq([


	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, [1],[5],[9],[11],
	\x,\x,\x,\x, [3],[5],[8],[10],
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, [2],\x,[4],\x,
	[7],\x,\x,\x, [1],[3],[5],[8],
	[10],\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,

	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,
	\x,\x,\x,\x, \x,\x,\x,\x,







], cycles).asStream;


//Synth1
~melody = {
	cycles.do{
		notePattern.do{ |v|
			if(v != \x,{

				//If \r, then pick a note at random
				if (v == \r,{
					i = rand(noteList.size).postln;
				},{
					i = (v - 1);
				});


				n = noteList[i];

				//Play all notes in subarray to create a chord
				n.do{ arg currentNote;

						s.bind{ Synth(\sine1,
						[\freq, ((currentNote.midicps) + (rand2(2))), // random for slight detune
						\slide, rrand(0.2,5),
						\slideTime, rrand(0.005, 0.07),
						\delayChance, 0.1.coin,
						\outDry, 0,
						\outFX, ~fxBus,
						\amp, -27.dbamp,
						\width, rrand(0.2,0.8),
						\sustain, 0.02,
						\release, ~dBeat*12,
						\dryLvl, 0.9,
						\wetLvl, 1,
						\pan, rand2(0.6),
						\wrapOn, 0.3,
						\fmFreq, rrand(600,800),
						\fmDepth, rrand(5,10),
						\lpfFreq, rrand(800,18000),
						\tranAmp, rrand(0.2,0.8),
						\widthEnd, rrand(0.1,0.9)
							],
							~sndGroup)
						}
				};

					}
				);

			rest.wait;
		};
	}
}.fork;


~drums = {
	(cycles-1).do { // Keep cycling
		//Drums
		pattern.do{ |triggerChar| //based on the character in the sequence, play the note or rest
			//Reset the randomizer
			instMap.add($? -> [\kick, \kick2, \snare, \hat, \glitch2, \rest].choose);

			//Rest if a "." or if "?" chooses Rest
			if((triggerChar == $.) || (instMap[triggerChar] == \rest), {
				//"REST".postln;
				rest.wait;
			}, {
				if((instMap[triggerChar].notNil), {

					//Play the drum synth
					s.bind{
						Synth(instMap[triggerChar],[
							\amp, rrand (0.7,1),
							\lengthMult, rrand (0.5, 3.4),
							\seqDur, rrand(0.03,0.09),
							\seqInt1, rrand(0.5,1),
							\seqInt2, rrand(1.2,1.5),
							\seqInt3, rrand(2,2.4),
							\seqInt4, rrand(2.8,7.2),
							\glitchPan, rand2(0.8),
							\hatPan, rand2(0.4)
						    ]
						);
					};

					rest.wait;
				});
			}
			)

		};

	}
}.fork;

)

//Recording
s.makeWindow;
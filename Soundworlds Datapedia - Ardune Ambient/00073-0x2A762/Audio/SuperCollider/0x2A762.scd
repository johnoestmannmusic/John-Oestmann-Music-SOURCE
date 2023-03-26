
(
//s.options.device_("ASIO : ASIO4ALL v2");
s.boot

)

//SOUND DESIGN///////////
//Using a synth with Patterns

//Sine Mallet
(
SynthDef("SineMallet",{arg freq=440, filtFreq=8000, amp= -8, pan = 0.0, curve = 1, ampMult = 1;
	var sound, env, filteredSound, reverbSound;

	//Building the sound
	sound=SinOsc.ar(freq,0,amp.dbamp);
	sound = sound.tanh.tanh;
	env = EnvGen.ar(Env([0,1,0],[0.01,1.4],[curve,0, curve]),doneAction:2); //doneAction is important to clear up memory

	Out.ar(0,Pan2.ar((sound*env*ampMult),pan))
}).add;


//Perc
SynthDef("TickPerc", {arg amp= -20, pan = 0.0, ampMult = 1, intense = 1;
	var sound, env;

	sound=WhiteNoise.ar(amp.dbamp*ampMult);
	sound = sound.tanh.tanh.tanh;
	env = EnvGen.ar(Env.perc(0.01,0.05*intense,1.0,-8), doneAction: Done.freeSelf);

	Out.ar(0,Pan2.ar((sound*env),pan))
}).add;


SynthDef("Snare", {arg amp= -15, intense = 1, lengthMult = 1, ampMult= 1, pan = 0.0;
	var sound, env, fullEnv, delaySound, iniHit;

	sound = SinOsc.ar(\freq.ar(150) * (1 + (\spike.kr(4) * Env.perc(0.001, [0.03, 0.08, 0.03, 0.12]*intense*lengthMult).ar)));

	fullEnv = EnvGen.ar(Env.perc(0.005,[0.05, 0.08, 0.12, 0.15]*intense*lengthMult*\envTime.kr(20),1.0,-8), doneAction: Done.freeSelf);

	sound = sound.sum;
	sound = sound.tanh.tanh;
	sound = sound * amp.dbamp;
	iniHit = sound;
	delaySound = CombL.ar(sound,0.2, \decayTime.kr(0.02), 2);
	sound = (iniHit * \coreAmp.kr(0.5)) + (delaySound* \decayAmp.kr(-10.dbamp));

	sound = Pan2.ar((sound*fullEnv), pan);


	Out.ar(0,sound*ampMult);
}).add;
)


//TEST/////////////////
Synth("SineMallet");
Synth("TickPerc");
Synth("Snare");


//ROUTINES///////////////
//Use the routine to play a note with parameter modulations here.
(

var s;
var noteList = [60, 62, 63, 65, 67, 68, 70];
var ampList = [-6, -7, -12, -16]-3;
var ampListPerc = [-19, -24, -28];
var detune = 3;

//Reset allVol
~allVol = 1.0;

r = Routine({
	loop{

		//~note.postln;

		//Sound
		Synth("SineMallet",[\freq, (~note.midicps + rrand(0,detune)),
			\amp,ampList.choose,
			\pan, rand2(0.8),
			\curve, rrand(-5,5),
			\ampMult, ~allVol
		]).yield; //Yield breaks the loop and lets us keep using next.
	}
});

p = Routine({
	loop{

		//~note2.postln;

		//Sound
		Synth("SineMallet",[\freq, ((~note2-12).midicps + rrand(0,detune)),
			\amp,(ampList.choose-1),
			\pan, rand2(0.8),
			\curve, rrand(-5,5),
			\ampMult, ~allVol
		]).yield; //Yield breaks the loop and lets us keep using next.
		}

});

~percRoutine = Routine({
	loop{
		Synth("TickPerc",[\amp, ampListPerc.choose,
			\pan, rand2(0.3),
			\intense, rrand(0.5,1.5),
			\ampMult, (~percVol*~allVol)
		]).yield;
		}
});


)

([20,18,16,12,8,6,14].normalize).postln;


(

var notePFSM = Pfsm([
	#[1],
	"Op1", #[2],
    "Op2", #[0],
	"Op3", #[1]
], inf).asStream;


20.do{
	notePFSM.next.postln;
};

)


//COMPOSITION//////////////
//Combining Routines and  multiple.do to create music
(
var waitTime = 0.8, waitTime2 = 0.4, waitTime3 = 1.6, percTimes = [0.8,0.4,0.2];
var cycles = inf;
var noteList = [60, 62, 63, 65, 67, 68, 70]+5;

//Finite State Machine Melodies and Rhythms
var notePFSM = Pfsm([
	#[0],
	noteList[0], #[4,4,2,3,1],
    noteList[1], #[2,6],
	noteList[2], #[3],
	noteList[3], #[0,0,0,1],
    noteList[4], #[5,2],
	noteList[5], #[6,4],
	noteList[6], #[0,0,4],
], inf).asStream;

var notePFSMSnare = Pfsm([
	#[0],
	noteList[0], #[4,4,2,3,1],
    noteList[1], #[2,6],
	noteList[2], #[3],
	noteList[3], #[0,0,0,1],
    noteList[4], #[5,2],
	noteList[5], #[6,4],
	noteList[6], #[0,0,4],
], inf).asStream;

var notePFSM2 = Pfsm([
	#[0],
	noteList[0], #[1,3,3,4,6,7,3]+6,
    noteList[1], #[0,2,3,4,5,6,0,3],
	noteList[2], #[1,0,3,4,6,7,0],
	noteList[3], #[1,2,0,4,5,6,7,0,3],
    noteList[4], #[1,2,0,5,6,7,0] + 12,
	noteList[5], #[1,2,4,0,6,7,0,3],
	noteList[6], #[2,3,4,5,0,0,0,3],

	noteList[1], #[2,3,4,5,6], //+6
	noteList[2], #[1,3,4,6,7],
	noteList[3], #[1,2,4,5,6,7],
    noteList[4], #[1,2,5,6,7] + 12,
	noteList[5], #[1,2,4,6,7],
	noteList[6], #[2,3,4,5],

	noteList[1], #[2,3,4,5,6] +6 , //+12
	noteList[2], #[1,3,4,6,7,0],
	noteList[3], #[1,2,4,5,6,7,0],
    noteList[4], #[1,2,5,6,7,0],
	noteList[5], #[1,2,4,6,7,0],
	noteList[6], #[2,3,4,5,0],
], inf).asStream;

var percWaits = Pfsm([
	#[0],
	0.8, #[0, 10 ,0,1], //0
    0.4, #[1,1,1,0,2], //1
	0.2, #[3,3,4], //2
	0.2, #[0,1], //3
	0.2, #[5], //4
	0.025, #[6], //5
	0.025, #[7], //6
	0.025, #[8], //7
	0.025, #[9], //8
	0.1, #[3,4], //9
	2.0, #[0, 11],//10
	1.2, #[0] //11

], inf).asStream;

var snareWaits = Pfsm([
	#[0],
	0.8, #[0,1,1,1,2,2,7], //0

    0.8, #[0], //1

	0.4, #[3], //2
	0.4, #[4], //3
	0.4, #[5], //4
	0.4, #[0], //5

	0.4, #[7], //6
	0.4, #[8], //7
	0.4, #[9], //8
	0.4, #[10], //9
	0.8, #[0], //10

], inf).asStream;

//TempoClock
TempoClock.tempo = 1.5;

//Voice 1
{
	cycles.do{
		arg t;


		~note = notePFSM.next;
		//~note.postln;

		r.next;
		if(0.5.coin, {waitTime.wait}, {waitTime2.wait});


	};
}.fork;

//Voice 2
{
	cycles.do{
		arg t;


		~note2 = notePFSM2.next;
		//~note.postln;

		p.next;

		waitTime3.wait;


	};
}.fork;

//Perc
{
	cycles.do{
		~percRoutine.next;
		percWaits.next.wait;

	};
}.fork;

//Snare-Tuned
{
	cycles.do{

		snareWaits.next.wait;

		Synth("Snare",[\intense,rrand(0.2,1.4),
			\decayTime, rrand(0.8, 2),
			\freq, notePFSMSnare.next().midicps,
			\spike, rrand(1,6),
			\envTime, rrand(20,50),
			\ampMult, (~snareVol*~allVol),
			\pan, rand2(0.8)
		])
	};
}.fork;


//AUTOMATION

//Perc and Snares Vol
{
	cycles.do{arg t;
		"Beat: ".post;
		t.postln;


		n = t-48; //Perc at 48 beats
		i = t-80; //Snare at 80 beats
		x = t-192; //All 3 start fading out after 192 beats

		"PercVolume: ".post;
		~percVol.postln;

		"SnareVolume: ".post;
		~snareVol.postln;

		"All Volume: ".post;
		~allVol.postln;

		//Perc
		if(n > 0.0,
			{

				if(~percVol < 1,
					{
						~percVol = (0.05 * n)}
				)
			},
			{
				~percVol = 0;
			}
		);

		//Snare
		if(i > 0.0,
			{

				if(~snareVol < 1,
					{
						~snareVol = (0.05 * i)}
				)
			},
			{
				~snareVol = 0;
			}
		);

		//AllVol
		if(x > 0.0,
			{

				if(~allVol > 0.0,
					{
						~allVol = ~allVol - 0.05

					}
				)
			},
			{
				~allVol = 1.0;
			}
		);
		////////////////

		1.0.wait;
	}
}.fork;


)

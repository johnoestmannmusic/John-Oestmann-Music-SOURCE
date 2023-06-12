// 0x2A764-ii | Deadlands Forest Shrine II
/*The truth of culture is that it spreads and evolves freely.
Released into the Public Domain / CC0. Free to access, study, remix and reuse.
Attribution is appreciated, but not required.*/

s.makeGui(w);

(
//Play the Track
{
	//Currently Playing
	~startBeat = 0;
	~endBeat = ~compLine1.size;
	//~endBeat = ~startBeat + 16;

	//Posting
	~instVis1 = "[]";
	~instVis2 = "[]";
	~instVis3 = "[]";

	//Run
	~beatIndex = ~startBeat;

	//Modulator
	Synth(\busFMAug);

	~play = {

		//Process
		//COMPLINE1
		if(~compLine1[~beatIndex].isArray == true,
			{
				~nextIndex1 = ~compLine1[~beatIndex];

				//Visual
				~instVis1 = (" [" + ~noteList[~nextIndex1[0]] +"]");

				//Note, FM Macro, NoteLength Macro, Amp
				Synth(\et4, [\carFreq: (~noteList[~nextIndex1[0]] + ~compLine1_trans).midicps,
					\macro1 , ~nextIndex1[1],
					\macro2 , ~nextIndex1[2],
					\amp , ~nextIndex1[3],
					\pan , rand2(0.6),
				]);
			},
			{

				~instVis1 = " -";

			}
		);

		//COMPLINE2
		//Use Modulo to wrap into Main Sequence
		~beatIndex2 = ~beatIndex % ~compLine2.size;

		if(~compLine2[~beatIndex2].isArray == true,
			{
				~nextIndex2 = ~compLine2[~beatIndex2];

				~instVis2 = (" [" + ~noteList[~nextIndex2[0]] +"]");

				//Note, FM Macro, NoteLength Macro, Amp
				Synth(\et4, [\carFreq: (~noteList[~nextIndex2[0]] + ~compLine2_trans).midicps,
					\macro1 , ~nextIndex2[1],
					\macro2 , ~nextIndex2[2],
					\amp , ~nextIndex2[3],
					\pan , 0,
				]);
			},
			{
				~instVis2 = " -";
			}

		);

		//COMPLINE3
		//Use Modulo to wrap into Main Sequence
		~beatIndex3 = ~beatIndex % ~compLine3.size;

		if(~compLine3[~beatIndex3].isArray == true,
			{
				~nextIndex3 = ~compLine3[~beatIndex3];

				~instVis3 = (" [" + ~noteList[~nextIndex3[0]] +"]");

				//Note, FM Macro, Attack Macro, NoteLength Macro, Amp
				Synth(\et5, [\carFreq: (~noteList[~nextIndex3[0]] + ~compLine3_trans).midicps,
					\macro1 , ~nextIndex3[1],
					\macro2 , ~nextIndex3[2],
					\macro2 , ~nextIndex3[3],
					\amp , ~nextIndex3[4],
					\pan , 0,
				]);
			},
			{
				~instVis3 = " -";
			}

		);

		//Visual
		(~beatIndex+1).post;
		" | ".post;
		~instVis1.post;
		~instVis2.post;
		~instVis3.postln;


		//Iterate
		~beatIndex = ~beatIndex + 1;

		if(~beatIndex >= ~endBeat,
			{~beatIndex = ~startBeat}
		);

		0.25.wait;
	}.loop;
}.fork;


)



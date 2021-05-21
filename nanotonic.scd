(

x=SynthDef("nanotonic", {
	arg out,
	oscFreq=20000,  oscAttack=0.003,oscDecay=0.04,
	pitchModRate=0.018,pitchModHz=20000,pitchModAmount=16,
	oscSine=1,oscSaw=0,oscLine=0,
	oscPitchImpulse=0,oscPitchSine=0,oscPitchWhite=1,
	nozFreq=4000,nozRes=1.0,nozAttack=0.027,nozDecay=0.152,
	nozLPF=0,nozBPF=0,nozHPF=0,nozStereoOn=1,
	nozEnv1On=0.0,nozEnv2On=0.0,nozEnv3On=1.0,
	eqFreq=123,eqGain=(0),distort=0,
	mixOsc=0,level=(0);
	var osc,noz,snd,val,index,wn;
	var pitchModImpulse,pitchModSine,pitchModRand,pitchMod;
	var nozEnv1,nozEnv2,nozEnv3,nozEnv;
	pitchModSine=SinOsc.ar(pitchModRate,0,pitchModHz);
	pitchModImpulse=Decay.ar(Impulse.ar(0.0001),pitchModRate,pitchModAmount.neg);
	pitchModRand={LFNoise0.ar(pitchModHz,pitchModAmount)}!2;
	pitchMod=(oscPitchImpulse*pitchModImpulse)+
	(oscPitchSine*pitchModSine)+
	(oscPitchWhite*pitchModRand);


	// mix in the the pitch mod
	oscFreq=(oscFreq.cpsmidi-pitchMod).midicps;
	osc=(oscSine*SinOsc.ar(oscFreq)) +
	(oscSaw*Saw.ar(oscFreq))+
		(oscLine*Phasor.ar(1,oscFreq/s.sampleRate,-0.4,0.4,0));

	// add oscillator envelope
	osc = osc*EnvGen.kr(Env.perc(oscAttack, oscDecay,1,[0,-4]),doneAction:((oscAttack+oscDecay)>(nozAttack+nozDecay))*2);

	// generate noise
	wn=WhiteNoise.ar();
	noz=wn;
	// stereo noise
	noz=((1-nozStereoOn)*noz)+(nozStereoOn!2*{WhiteNoise.ar()}!2);
	// noise envelopes
	nozEnv1=EnvGen.kr(Env.perc(nozAttack,nozDecay,1,[4,-4]),doneAction:((oscAttack+oscDecay)<(nozAttack+nozDecay))*2);
	nozEnv2=EnvGen.kr(Env.linen(nozAttack,0,nozDecay),doneAction:((oscAttack+oscDecay)<(nozAttack+nozDecay))*2);
	nozEnv3=(1-(LFPulse.ar((0.00001/nozAttack).poll,0,0.5,-1,1)*Trig.ar(1,nozAttack)))*EnvGen.ar(Env.linen(0.0,nozAttack,nozDecay,curve:\cubed));
	// nozEnv=(nozEnv1On*nozEnv1)+(nozEnv2On*nozEnv2)+(nozEnv3On*nozEnv3);
	nozEnv=nozEnv3;
	// noz=noz+(nozLPF*RLPF.ar(noz,nozFreq,nozRes));
	noz=BPF.ar(noz,nozFreq,nozRes);
	// noz=noz+(nozHPF*RHPF.ar(noz,nozFreq,nozRes));

	noz = noz*nozEnv;


	snd=((mixOsc/100)*osc)+((1-(mixOsc/100))*noz);
	snd=(snd*(distort+1/5)*5).tanh/5;
	snd=BPeakEQ.ar(snd,eqFreq,1,eqGain);
	Out.ar(0, snd*level.dbamp*0.5);
}).play;
)

(
{
	var nozAttack=0.08;
	var nozDecay=0.5;
	//LFPulse.ar(1/nozAttack,0.5,0.5,1)
	(1-(LFPulse.ar(5/nozAttack,0,0.5,-1,1)*Trig.ar(1,nozAttack)))
	*EnvGen.ar(Env.linen(0.0,nozAttack,nozDecay,curve:\cubed))
}.plot(0.5);
)

Env.perc(0.05,0.5,1.0,[4,-4]).plot

{(WhiteNoise.ar()*Trig.ar(1,0.05))+EnvGen.ar(Env.perc(0.01,0.5,1.0,-4))}.plot(1)
{Trig.ar(1,0.5)}.plot(1)

Env([1,0,1],[1,1]).plot

{ Decay.ar(Impulse.ar(0.01),0.1,-0.5) }.plot(1);

{Phasor.ar(1,440/s.sampleRate,-1,1,0)}.play;

Line

(3==3).asInteger.asFloat;

-60.dbamp


// presetfile:
MicrotonicPresetV3: {
	Pattern: "a"
	StepRate: "1/16"
	Swing: "0.0%"
	FillRate: "2.0x"
	MastVol: "0.0 dB"
	Mutes: { "Off", "Off", "Off", "Off", "Off", "Off", "Off", "Off" }
	DrumPatches: {
		"1": {
			Name: "SC BD Construct"
			Modified: true
			Path: "./By Category/Bass Drum Patches/SC BD Construct.mtdrum"
			OscWave: "Triangle"
			OscFreq: "44.774406794226124 Hz"
			OscAtk: "0.0 ms"
			OscDcy: "859.4069398372394 ms"
			ModMode: "Decay"
			ModRate: "339.8732275792698 ms"
			ModAmt: "36.902400567626955 sm"
			NFilMod: "LP"
			NFilFrq: "69.34731641146828 Hz"
			NFilQ: "2.5692426661038357"
			NStereo: "Off"
			NEnvMod: "Exp"
			NEnvAtk: "26.68178034809035 ms"
			NEnvDcy: "181.96632325047455 ms"
			Mix: "82.0 / 18.0"
			DistAmt: "41.6608989238739"
			EQFreq: "71.93038091762848 Hz"
			EQGain: "35.14383792877197 dB"
			Level: "-4.7643641884096635 dB"
			Pan: "0.0"
			Output: "A"
			Choke: "Off"
			OscVel: "66.00000262260437%"
			NVel: "33.000001311302185%"
			ModVel: "37.00000047683716%"
		}
		"2": {
			Name: "VT-707 SD 2"
			Modified: true
			Path: "./By Category/Snare Drum Patches/VT-707 SD 2.mtdrum"
			OscWave: "Triangle"
			OscFreq: "152.8933594221613 Hz"
			OscAtk: "3.0966784155590314 ms"
			OscDcy: "53.623965431016956 ms"
			ModMode: "Decay"
			ModRate: "18.406874794786347 ms"
			ModAmt: "96.0 sm"
			NFilMod: "LP"
			NFilFrq: "6147.8776054666605 Hz"
			NFilQ: "0.7071068285880863"
			NStereo: "Off"
			NEnvMod: "Linear"
			NEnvAtk: "6.5824782478977975 ms"
			NEnvDcy: "120.45888086021432 ms"
			Mix: "93.79293823242187 / 6.207059860229492"
			DistAmt: "87.64028549194336"
			EQFreq: "135.79211852923444 Hz"
			EQGain: "7.500629425048828 dB"
			Level: "-7.304181757268102 dB"
			Pan: "0.0"
			Output: "A"
			Choke: "Off"
			OscVel: "40.00000059604645%"
			NVel: "33.000001311302185%"
			ModVel: "30.000001192092896%"
		}
		"3": {
			Name: "SC HH Lemon"
			Modified: true
			Path: "./By Category/Hi-hats And Cymbal Patches/SC HH Lemon.mtdrum"
			OscWave: "Sine"
			OscFreq: "19999.999999999996 Hz"
			OscAtk: "0.0 ms"
			OscDcy: "195.29790053327372 ms"
			ModMode: "Noise"
			ModRate: "8364.710582308451 Hz"
			ModAmt: "17.27998077393113 sm"
			NFilMod: "HP"
			NFilFrq: "3673.695774523278 Hz"
			NFilQ: "0.7319558947087429"
			NStereo: "Off"
			NEnvMod: "Exp"
			NEnvAtk: "0.0 ms"
			NEnvDcy: "219.043978711439 ms"
			Mix: "50.0 / 50.0"
			DistAmt: "0.0"
			EQFreq: "158.1138834308664 Hz"
			EQGain: "-13.199999332427979 dB"
			Level: "-4.926389210122775 dB"
			Pan: "-24.000000953674316"
			Output: "A"
			Choke: "Off"
			OscVel: "44.99999284744263%"
			NVel: "46.99999988079071%"
			ModVel: "30.000001192092896%"
		}
		"4": {
			Name: "AC Rev HitIt2"
			Modified: true
			Path: "./By Category/Effect Patches/AC Rev HitIt2.mtdrum"
			OscWave: "Sine"
			OscFreq: "363.27086550059727 Hz"
			OscAtk: "0.0 ms"
			OscDcy: "208.12533664050576 ms"
			ModMode: "Sine"
			ModRate: "51.14957478933808 Hz"
			ModAmt: "29.05758507628957 sm"
			NFilMod: "LP"
			NFilFrq: "2448.816620601219 Hz"
			NFilQ: "1.1449613832455137"
			NStereo: "Off"
			NEnvMod: "Exp"
			NEnvAtk: "244.70480064178315 ms"
			NEnvDcy: "5075.704278068058 ms"
			Mix: "0.0 / 100.0"
			DistAmt: "6.599930673837662"
			EQFreq: "1068.7781963618504 Hz"
			EQGain: "30.05779266357422 dB"
			Level: "-9.091618067701987 dB"
			Pan: "0.0"
			Output: "A"
			Choke: "Off"
			OscVel: "37.23784685134888%"
			NVel: "40.16443192958832%"
			ModVel: "46.01492881774902%"
		}
		"5": {
			Name: "EM BD Young909"
			Modified: true
			Path: "./By Category/Bass Drum Patches/EM BD Young909.mtdrum"
			OscWave: "Triangle"
			OscFreq: "44.89061126326647 Hz"
			OscAtk: "0.0 ms"
			OscDcy: "715.7838018002783 ms"
			ModMode: "Decay"
			ModRate: "207.97039159862362 ms"
			ModAmt: "38.880721872004415 sm"
			NFilMod: "LP"
			NFilFrq: "354.56680198851154 Hz"
			NFilQ: "0.7071059794298696"
			NStereo: "Off"
			NEnvMod: "Linear"
			NEnvAtk: "18.057170712283696 ms"
			NEnvDcy: "256.03105506411583 ms"
			Mix: "86.60225677490234 / 13.397741317749023"
			DistAmt: "27.505573630332947"
			EQFreq: "52.215453367657496 Hz"
			EQGain: "15.444450378417969 dB"
			Level: "-0.4999987051049255 dB"
			Pan: "0.0"
			Output: "A"
			Choke: "Off"
			OscVel: "37.00000047683716%"
			NVel: "28.999996185302734%"
			ModVel: "27.000001072883606%"
		}
		"6": {
			Name: "SC SD rorriM"
			Modified: true
			Path: "./By Category/Snare Drum Patches/SC SD rorriM.mtdrum"
			OscWave: "Sine"
			OscFreq: "281.44883605982625 Hz"
			OscAtk: "396.43271803825536 ms"
			OscDcy: "10.0 ms"
			ModMode: "Sine"
			ModRate: "0.5055165784519348 Hz"
			ModAmt: "-39.78455615678473 sm"
			NFilMod: "LP"
			NFilFrq: "5652.38341432925 Hz"
			NFilQ: "0.7071068285880863"
			NStereo: "Off"
			NEnvMod: "Exp"
			NEnvAtk: "396.43289315227463 ms"
			NEnvDcy: "10.0 ms"
			Mix: "64.16667175292969 / 35.83333206176758"
			DistAmt: "24.741262197494507"
			EQFreq: "297.536794057205 Hz"
			EQGain: "-33.66796374320984 dB"
			Level: "-2.3768811356920025 dB"
			Pan: "0.0"
			Output: "A"
			Choke: "Off"
			OscVel: "34.93611514568329%"
			NVel: "42.613932490348816%"
			ModVel: "40.00000059604645%"
		}
		"7": {
			Name: "VT-MP7 OH"
			Modified: true
			Path: "./By Category/Hi-hats And Cymbal Patches/VT-MP7 OH.mtdrum"
			OscWave: "Sine"
			OscFreq: "1591.8975003475666 Hz"
			OscAtk: "0.0 ms"
			OscDcy: "131.97203341412876 ms"
			ModMode: "Sine"
			ModRate: "71.58553051836344 Hz"
			ModAmt: "0.5162641724273271 sm"
			NFilMod: "HP"
			NFilFrq: "1470.7777886134322 Hz"
			NFilQ: "0.7648127524634291"
			NStereo: "Off"
			NEnvMod: "Exp"
			NEnvAtk: "4.012899778893083 ms"
			NEnvDcy: "697.2256538596694 ms"
			Mix: "0.00000762939453125 / 99.99999237060547"
			DistAmt: "15.912890434265137"
			EQFreq: "9364.513348062286 Hz"
			EQGain: "11.873140335083008 dB"
			Level: "-11.187254098872323 dB"
			Pan: "0.0"
			Output: "A"
			Choke: "Off"
			OscVel: "27.000001072883606%"
			NVel: "30.000001192092896%"
			ModVel: "30.000001192092896%"
		}
		"8": {
			Name: "KM CLP 01"
			Modified: true
			Path: "./By Category/Percussion Patches/KM CLP 01.mtdrum"
			OscWave: "Sine"
			OscFreq: "523.2510879162271 Hz"
			OscAtk: "0.0 ms"
			OscDcy: "316.2277660168379 ms"
			ModMode: "Decay"
			ModRate: "353.3333333333333 ms"
			ModAmt: "0.0 sm"
			NFilMod: "BP"
			NFilFrq: "834.2749211206592 Hz"
			NFilQ: "0.7071068285880863"
			NStereo: "Off"
			NEnvMod: "Mod"
			NEnvAtk: "27.169952780835565 ms"
			NEnvDcy: "152.17838124737696 ms"
			Mix: "0.0 / 100.0"
			DistAmt: "23.999999463558197"
			EQFreq: "146.83235470727567 Hz"
			EQGain: "-40.0 dB"
			Level: "-11.439378669331125 dB"
			Pan: "21.746480464935303"
			Output: "A"
			Choke: "Off"
			OscVel: "21.99999988079071%"
			NVel: "17.999999225139618%"
			ModVel: "27.000001072883606%"
		}
	}
	Patterns: {
		a: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		b: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		c: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		d: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		e: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		f: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		g: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		h: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		i: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		j: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		k: {
			Length: 16
			Chained: false
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
		l: {
			Length: 16
			"1": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"2": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"3": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"4": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"5": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"6": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"7": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
			"8": {
				Triggers: "----------------"
				Accents:  "----------------"
				Fills:    "----------------"
			}
		}
	}
}

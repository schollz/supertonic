(
SynthDef("nanotonic", {
	arg out,
	oscFreq=54,oscAtk=0,oscDcy=500,
	modRate=400,modAmt=18,
	oscWave=0,modMode=0,
	nFilFrq=1000,nFilQ=2.5,nEnvAtk=26,nEnvDcy=200,
	nFilMod=0,nStereo=1,nEnvMod=0,
	eQFreq=500,eQGain=(-20),distAmt=2,
	mix=95,level=(-5);

	// variables
	var osc,noz,nozPostF,snd,pitchMod,nozEnv;

	// convert to seconds from milliseconds
	oscAtk=oscAtk/1000;
	oscDcy=oscDcy/1000;
	modRate=modRate/1000;
	nEnvAtk=nEnvAtk/1000;
	nEnvDcy=nEnvDcy/1000;

	// define pitch modulation
	pitchMod=Select.ar(modMode,[
		Decay.ar(Impulse.ar(0.0001),modRate,modAmt.neg), // decay
		SinOsc.ar(modRate,0,modAmt), // sine
		LPF.ar(WhiteNoise.ar(),1/modRate,modAmt), // random
	]);


	// mix in the the pitch mod
	oscFreq=(oscFreq.cpsmidi-pitchMod).midicps;

	// define the oscillator
	osc=Select.ar(oscWave,[
		SinOsc.ar(oscFreq),
		LFTri.ar(oscFreq),
		Saw.ar(oscFreq),
	]);

	// add oscillator envelope
	osc = osc.dup*EnvGen.kr(Env.perc(oscAtk, oscDcy,1,[0,-4]),doneAction:((oscAtk+oscDcy+(rrand(0,1000)/1000000))>(nEnvAtk+nEnvDcy))*2);

	// generate noise
	noz=WhiteNoise.ar();

	// optional stereo noise
	noz=((1-nStereo)*noz)+(nStereo!2*{WhiteNoise.ar()}!2);

	// define noise envelope
	nozEnv=Select.kr(nEnvMod,[
		EnvGen.kr(Env.perc(nEnvAtk,nEnvDcy,1,[4,-4]),doneAction:((oscAtk+oscDcy)<(nEnvAtk+nEnvDcy))*2),
		EnvGen.kr(Env.linen(nEnvAtk,0,nEnvDcy)),
		(1-(LFPulse.ar(200,0,0.45,-1,1)*Trig.ar(1,nEnvAtk)))*EnvGen.ar(Env.linen(0.0,nEnvAtk,nEnvDcy,curve:\cubed)),
	]);

	// apply noise filter
	nozPostF=Select.ar(nFilMod,[
		RLPF.ar(noz,nFilFrq,nFilQ),
		BPF.ar(noz,nFilFrq,nFilQ),
		HPF.ar(noz,nFilFrq,nFilQ)
	]);

	// apply envelope to noise
	noz = nozPostF*nozEnv;

	// mix oscillator and noise
	snd=((mix/100)*osc)+((1-(mix/100))*noz);

	// apply distortion
	snd=((distAmt<0.01)*snd)+((distAmt>0)*SineShaper.ar(snd,1.0,1+(distAmt/5)));

	// apply eq
	snd=BPeakEQ.ar(snd,eQFreq,1,eQGain);

	// level
	Out.ar(0, snd*level.dbamp*0.5);
}).add;
)

(rrand(0,1000)/1000000)

(
{
	var modMode=0,modAmt=(64),modRate=1,mod;
mod=Select.kr(modMode,[
		Decay.ar(Impulse.ar(0.0001),modRate,modAmt.neg), // decay
		SinOsc.ar(modRate,0,modAmt), // sine
		LPF.ar(WhiteNoise.ar(),1/modRate,modAmt), // random
	]);
	mod
}.plot(0.5);
)

(
{
	var nEnvAtk=0.08;
	var nEnvDcy=0.5;
	//LFPulse.ar(1/nEnvAtk,0.5,0.5,1)
	(1-(LFPulse.ar(5/nEnvAtk,0,LFNoise0.kr(100).range(0.2,0.6),-1,1)*Trig.ar(1,nEnvAtk)))
	*EnvGen.ar(Env.linen(0.0,nEnvAtk,nEnvDcy,curve:\cubed))
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


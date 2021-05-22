(
SynthDef("nanotonic", {
	arg out,
	oscFreq=54,oscAtk=0,oscDcy=500,
	modRate=400,modAmt=18,
	oscWaveSine=1,oscWaveTriangle=0,oscWaveRamp=0,
	modModeDecay=1,modModeSine=0,modModeNoise=0,
	nFilFrq=1000,nFilQ=2.5,nEnvAtk=26,nEnvDcy=200,
	nFilModLP=0,nFilModBP=1,nFilModHP=0,nStereo=1,
	nEnvModLinear=0.0,nEnvModExp=0.0,nEnvModMod=1.0,
	eQFreq=500,eQGain=(-20),distAmt=2,
	mix=95,level=(-5);
	var osc,noz,nozPostF,snd,val,index,wn;
	var pitchModImpulse,pitchModSine,pitchModRand,pitchMod;
	var nozEnv1,nozEnv2,nozEnv3,nozEnv;

	// convert to seconds
	oscAtk=oscAtk/1000;
	oscDcy=oscDcy/1000;
	modRate=modRate/1000;
	nEnvAtk=nEnvAtk/1000;
	nEnvDcy=nEnvDcy/1000;

	// define pitch modulators
	pitchModImpulse=Decay.ar(Impulse.ar(0.0001),modRate,modAmt.neg);
	pitchModRand={LFNoise0.ar(1/modRate,modAmt)}!2;
	pitchModSine=SinOsc.ar(modRate,0,1/modRate);

	// define pitch modulation
	pitchMod=(modModeDecay*pitchModImpulse)+
	(modModeSine*pitchModSine)+
	(modModeNoise*pitchModRand);


	// mix in the the pitch mod
	oscFreq=(oscFreq.cpsmidi-pitchMod).midicps;
	osc=(oscWaveSine*SinOsc.ar(oscFreq)) +
	(oscWaveTriangle*Saw.ar(oscFreq))+
		(oscWaveRamp*Phasor.ar(1,oscFreq/s.sampleRate,-0.4,0.4,0));

	// add oscillator envelope
	osc = osc*EnvGen.kr(Env.perc(oscAtk, oscDcy,1,[0,-4]),doneAction:((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy))*2);

	// generate noise
	wn=WhiteNoise.ar();
	noz=wn;
	// stereo noise
	noz=((1-nStereo)*noz)+(nStereo!2*{WhiteNoise.ar()}!2);
	// noise envelopes
	nozEnv1=EnvGen.kr(Env.linen(nEnvAtk,0,nEnvDcy));
	nozEnv2=EnvGen.kr(Env.perc(nEnvAtk,nEnvDcy,1,[4,-4]),doneAction:((oscAtk+oscDcy)<(nEnvAtk+nEnvDcy))*2);
	nozEnv3=(1-(LFPulse.ar(100,0,0.45,-1,1)*Trig.ar(1,nEnvAtk)))*EnvGen.ar(Env.linen(0.0,nEnvAtk,nEnvDcy,curve:\cubed));
	nozEnv=(nEnvModLinear*nozEnv1)+(nEnvModExp*nozEnv2)+(nEnvModMod*nozEnv3);

	// apply noise filter
	nozPostF=BPF.ar(noz,nFilFrq,nFilQ,nFilModBP);
	nozPostF=nozPostF+RHPF.ar(noz,nFilFrq,nFilQ,nFilModHP);
	nozPostF=nozPostF+RLPF.ar(noz,nFilFrq,nFilQ,nFilModLP);

	noz = nozPostF*nozEnv;

	//mix=LinLin.kr(mix,0,100,95,100);
	// osc=Compander.ar(osc);
	// noz=Compander.ar(noz);
	snd=((mix/100)*osc)+((1-(mix/100))*noz);
	snd=(snd*(distAmt+1/5)*5).tanh/5;
	snd=BPeakEQ.ar(snd,eQFreq,1,eQGain);
	Out.ar(0, snd*level.dbamp*0.5);
}).add;
)

(
SynthDef("clap", {
    arg delay = #[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], rel=0.1, freq=600;

    var osc = Mix.arFill(10, { arg i;
        PinkNoise.ar()*0.3*EnvGen.ar(Env([0,0,1,0],[delay[i], 0.001, rel]), curve: \exp , doneAction: 0);
    });

    var snd =  BHiPass.ar(osc,freq);
    Out.ar(0,Pan2.ar(snd))
}).add;

x = Synth.new("clap", ["delay",Array.fill(15,{rrand(0.001,0.1)}), "rel", rrand(0.05,0.2), "freq", rrand(100,2000)]);
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


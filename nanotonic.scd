(
SynthDef("nanotonic", {
	arg out,
	oscFreq=80,  oscAttack=0.0,oscDecay=0.5,pitchModRate=0.1,
	nozFreq=12000,nozRes=0.5,nozAttack=0.01,nozDecay=0.2,
	nozLPF=1,nozBPF=0,nozHPF=0,
	mix=0.1;
	var osc,noz,snd;
	var pitchModImpulse,pitchModSine,pitchModRand,pitchMod;
	var nozEnv1,nozEnv2,nozEnv3,nozEnv;
	pitchModSine=SinOsc.ar(pitchModRate,0).range(0.99,1.00);
	pitchModImpulse={Decay.ar(Impulse.ar(0.001),1/pitchModRate)}!2;
	pitchModRand={LFNoise0.ar(pitchModRate).range(0.95,1.05)}!2;
	pitchMod=pitchModImpulse;
	osc=SinOsc.ar(oscFreq*pitchMod);
	osc=Saw.ar(oscFreq*pitchMod);
	osc=Phasor.ar(1,oscFreq/s.sampleRate*pitchMod,-0.4,0.4,0);
	osc = osc*EnvGen.ar(Env.perc(oscAttack, oscDecay));


	noz={WhiteNoise.ar()}.dup;
	nozEnv1=EnvGen.ar(Env.linen(nozAttack,0,nozDecay));
	nozEnv2=EnvGen.ar(Env.perc(nozAttack,nozDecay,1,[4,-4]));
	nozEnv3={(WhiteNoise.ar()*Trig.ar(1,nozAttack))+EnvGen.ar(Env.perc(nozAttack,nozDecay,1.0,-4))}!2;
	nozEnv=nozEnv1;
	noz=noz+(nozLPF*RLPF.ar(noz,nozFreq,nozRes));
	noz=noz+(nozBPF*BPF.ar(noz,nozFreq,nozRes));
	noz=noz+(nozHPF*RHPF.ar(noz,nozFreq,nozRes));
	noz = noz*nozEnv;

	snd=((1-mix)*osc)+(mix*noz);
	Out.ar(0, snd);
}).play;
)

Env.linen(0.03,0,0.1).plot
Env.perc(0.05,0.5,1.0,[4,-4]).plot

{(WhiteNoise.ar()*Trig.ar(1,0.05))+EnvGen.ar(Env.perc(0.01,0.5,1.0,-4))}.plot(1)
{Trig.ar(1,0.5)}.plot(1)

Env([1,0,1],[1,1]).plot
plot({ Decay.ar(Impulse.ar(0.01),0.1) });

{Phasor.ar(1,440/s.sampleRate,-1,1,0)}.play;

Line

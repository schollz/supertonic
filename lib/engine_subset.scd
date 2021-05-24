(
SynthDef("nanotonic", {
    arg out,
    mix=50,level=(-5),distAmt=2,
    eQFreq=632.4,eQGain=(-20),
    oscAtk=0,oscDcy=500,
    oscWave=0,oscFreq=54,
    modMode=0,modRate=400,modAmt=18,
    nEnvAtk=26,nEnvDcy=200,
    nFilFrq=1000,nFilQ=2.5,
    nFilMod=0,nEnvMod=0,nStereo=1,
    oscLevel=1,nLevel=1;

    // variables
    var osc,noz,nozPostF,snd,pitchMod,nozEnv,numClaps,oscFreeSelf,wn1,wn2,click,clickTrigger,clapFrequency;

    // convert to seconds from milliseconds
	oscAtk=DC.kr(oscAtk/1000);
	oscDcy=DC.kr(oscDcy/1000);
	modRate=DC.kr(modRate/1000);
	nEnvAtk=DC.kr(nEnvAtk/1000);
	nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
	level=DC.kr(level*1.5);

    // white noise generators (expensive)
    wn1=WhiteNoise.ar();
    wn2=WhiteNoise.ar();
    clickTrigger=Trig.ar(1,0.005);
	clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
    // determine who should free
	oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

    // define pitch modulation
    pitchMod=Select.ar(modMode,[
        Decay.ar(Impulse.ar(0.0001),modRate,modAmt.neg), // decay
        SinOsc.ar(modRate,0,modAmt), // sine
        LPF.ar(wn2,1/modRate,modAmt), // random
    ]);

    // mix in the the pitch mod
    oscFreq=(oscFreq.cpsmidi-pitchMod).midicps;

    // define the oscillator
    osc=Select.ar(oscWave,[
        SinOsc.ar(oscFreq+5),
        LFTri.ar(oscFreq+5),
        SawDPW.ar(oscFreq),
    ]);

     // Add click to signal when attack is less than 2ms
    click = SelectX.ar(LinLin.kr(oscAtk,0, 0.002, 0, 1), [clickTrigger, DC.ar(0)]);

    // add oscillator envelope
    osc = Splay.ar(osc*EnvGen.kr(Env.perc(oscAtk, oscDcy,1,[0,-4]),doneAction:oscFreeSelf)+click);

    // generate noise
    noz=wn1;

    // optional stereo noise
    noz=Select.ar(nStereo,[wn1,[wn1,wn2]]);


    // define noise envelope
    nozEnv=Select.kr(nEnvMod.poll,[
        EnvGen.kr(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential),doneAction:(2-oscFreeSelf)),
        EnvGen.kr(Env.linen(nEnvAtk,0,nEnvDcy)),
		Trig.kr(Impulse.kr(clapFrequency),0.005)/2+EnvGen.ar(Env.perc(0,2/clapFrequency,curve:[4,-4]),(1-Impulse.ar(clapFrequency)))*Trig.ar(1,nEnvAtk)+EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential)),
    ]);




    // apply noise filter
    nozPostF=Select.ar(nFilMod,[
        BLowPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
        BBandPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
        BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
    ]);
    // special Q
    nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

    // add click
    click = SelectX.ar(LinLin.kr(nEnvAtk,0, 0.002, 0, 1), [clickTrigger, DC.ar(0)]);

    // apply envelope to noise
    noz = Splay.ar(nozPostF*nozEnv);
    noz=noz+Splay.ar(click);


    // mix oscillator and noise
    snd=SelectX.ar(mix/100,[noz*nLevel.dbamp/2,osc*oscLevel/2]);


    // apply distortion
    snd=SelectX.ar(distAmt/100,[
        (snd+(snd*distAmt/4)),
        SineShaper.ar(snd,1.0,Clip.kr(distAmt-40,1,100)),
    ]).softclip;

    // apply eq after distortion
    snd=BPeakEQ.ar(snd,eQFreq,1,eQGain);


    snd=HPF.ar(snd,20);

    // level
    Out.ar(0, snd*level.dbamp*0.1);
}).play;
)


(
Synth("nanotonic",[
\distAmt,0,
\eQFreq,100,
\eQGain,0,
\level,0,
\mix,0,
\modAmt,0,
\modMode,0,
\modRate,18.406874794786,
\nEnvAtk,200,
\nEnvDcy,0,
\nEnvMod,2,
\nFilFrq,5000,
\nFilMod,2,
\nFilQ,0.70710682858809,
\nStereo,0,
\oscAtk,3.096678415559,
\oscDcy,53.623965431017,
\oscFreq,152.89335942216,
\oscWave,1,
]);
)


(
{
	var clapFrequency=30,nEnvAtk=200,nEnvDcy=0;
	Trig.kr(Impulse.kr(clapFrequency),0.005)/2+EnvGen.kr(Env.perc(0,2/clapFrequency,curve:[0,-4]),(Impulse.kr(clapFrequency)))*Trig.kr(1,nEnvAtk)+EnvGen.kr(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential))
}.plot(0.5);
)

Decay
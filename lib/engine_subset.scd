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
    oscLevel=1,nLevel=1,
    oscVel=100
    ;

    // variables
    var osc,noz,nozPostF,snd,pitchMod,nozEnv,numClaps,oscFreeSelf,wn1,wn2,clapFrequency;

    // convert to seconds from milliseconds
    oscAtk=DC.kr(oscAtk/1000);
    oscDcy=DC.kr(oscDcy/1000);
    modRate=DC.kr(modRate/1000);
    nEnvAtk=DC.kr(nEnvAtk/1000);
    nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
    level=DC.kr(level);

    // white noise generators (expensive)
    wn1=WhiteNoise.ar();
    wn2=WhiteNoise.ar();
    clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
    // determine who should free
    oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

    // define pitch modulation
    pitchMod=Select.ar(modMode,[
        Decay.ar(Impulse.ar(0.0001),modRate), // decay
        SinOsc.ar(-1/modRate), // sine
        Lag.ar(LFNoise0.ar(4/modRate),modRate/4).poll, // random
    ]);

    // mix in the the pitch mod
    oscFreq=(oscFreq.cpsmidi+(pitchMod*modAmt)).poll.midicps;

    // define the oscillator
    osc=Select.ar(oscWave,[
        SinOsc.ar(oscFreq+5),
        LFTri.ar(oscFreq+5)*0.5,
        SawDPW.ar(oscFreq)*0.5,
    ]);

    // increase volume
    //osc=(osc*LinLin.kr(oscVel,0,200,2,0)).softclip;

    // add oscillator envelope
    osc = osc*SelectX.ar(Clip.kr(LinLin.kr(oscAtk,0,0.1,0,1)).poll,[
        Decay.ar(Impulse.ar(0),oscDcy),
        EnvGen.ar(Env.perc(oscAtk, oscDcy,1,[0,-4]),doneAction:oscFreeSelf)
    ]);

    // generate noise
    noz=wn1;

    // optional stereo noise
    noz=Select.ar(nStereo,[wn1,[wn1,wn2]]);


    // define noise envelope
    nozEnv=Select.kr(nEnvMod,[
        EnvGen.kr(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential),doneAction:(2-oscFreeSelf)),
        EnvGen.kr(Env.linen(nEnvAtk,0,nEnvDcy)),
        Decay.ar(Impulse.ar(clapFrequency),1/clapFrequency,0.85,0.15)*Trig.ar(1,nEnvAtk+0.001)+EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential)),
    ]);

    // apply noise filter
    nozPostF=Select.ar(nFilMod,[
        BLowPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
        BBandPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
        BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
    ]);
    // special Q
    nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

    // apply envelope to noise
	noz=Splay.ar(nozPostF*nozEnv);

    // mix oscillator and noise
    snd=SelectX.ar(mix/100,[noz*nLevel.dbamp,osc*oscLevel]);

    // apply distortion
    snd=SelectX.ar(distAmt/100,[
        (snd+(snd*distAmt/4)),
        SineShaper.ar(snd,1.0,Clip.kr(distAmt-40,1,100)),
    ]).softclip;

    // apply eq after distortion
    snd=BPeakEQ.ar(snd,eQFreq,1,eQGain/2);

    snd=HPF.ar(snd,20);

    // level
    Out.ar(0, snd*level.dbamp*0.05);
}).add;
)

(
Synth("nanotonic",[
    \distAmt,0,
    \eQFreq,50,
    \eQGain,0,
    \level,0,
    \mix,50,
    \nEnvMod,0,
    \nFilFrq,500,
    \nFilMod,2,
    \nFilQ,0.7,
    \nStereo,0,
    \nEnvAtk,0,
    \nEnvDcy,84,
	\nLevel,1,
]);
)


(
Synth("nanotonic",[
    \distAmt,0,
    \eQGain,0,
    \level,0,
    \mix,100,
    \modAmt,29,
    \modMode,2,
    \modRate,1000/7515,
    \oscAtk,0,
    \oscDcy,68,
    \oscFreq,251,
    \oscWave,0,
    \oscVel,0,
]);
)

// Name: "RD GSn"
(
Synth("nanotonic",[
    \distAmt,0,
    \eQFreq,59.707651558903,
    \eQGain,-22,
    \level,10,
    \mix,50,
    \modAmt,29,
    \modMode,2,
    \modRate,1000/7515,
    \nEnvAtk,0,
    \nEnvDcy,372,
    \nEnvMod,0,
    \nFilFrq,245.05603577429,
    \nFilMod,2,
    \nFilQ,148.37726231182,
    \nStereo,0,
    \oscAtk,0,
    \oscDcy,68,
    \oscFreq,251,
    \oscWave,0,
    \oscVel,0,
]);
)



// Name: "SC SD rorriM"
(
Synth("nanotonic",[
    \distAmt,24,
    \eQFreq,277.5367940572,
    \eQGain,0,
    \level,-2.3,
    \mix,6,
    \modAmt,-39.784556156785,
    \modMode,1,
    \modRate,2000,
    \nEnvAtk,396.43289315227,
    \nEnvDcy,10.0,
    \nEnvMod,0,
    \nFilFrq,5652.3834143292,
    \nFilMod,0,
    \nFilQ,0.70710682858809,
    \nStereo,0,
    \oscAtk,396,
    \oscDcy,10.0,
    \oscFreq,531,
    \oscWave,0,
]);
)

// VT-909 Clap
(
Synth("nanotonic",[
    \distAmt,0,
    \eQFreq,784,
    \eQGain,22,
    \level,0,
    \mix,4,
    \modAmt,-45,
    \modMode,3,
    \modRate,1000/4100,
    \nEnvAtk,31,
    \nEnvDcy,152,
    \nEnvMod,2,
    \nFilFrq,3748,
    \nFilMod,1,
    \nFilQ,0.44,
    \nStereo,1,
    \oscAtk,93,
    \oscDcy,749,
    \oscFreq,1084,
    \oscWave,1,
]);
)




(
{
    //(1-LFSaw.ar(100,pi,0.5,0.5));
    Decay.ar(Impulse.ar(20),1/20,0.85,0.15)*WhiteNoise.ar;
    //EnvGen.kr(Env.new(levels:[1,0.2,1],times:[1/100,0],curve:[\exponential,\step]),Impulse.kr(100));
}.plot(0.5);
)

(
{
    var nEnvAtk=0.0,nEnvDcy=0.1;
    EnvGen.kr(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential));
}.plot(0.02)
)

(
{
    var clapFrequency=30;
    var nEnvAtk=0.1;
    var nEnvDcy=0.2;
    Decay.ar(Impulse.ar(clapFrequency),1/clapFrequency,0.85,0.15)*Trig.ar(1,nEnvAtk+0.001)+EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential))*WhiteNoise.ar
}.plot(0.1)
)

(
{
    Decay.ar(Impulse.ar(0),0.01);
}.plot(0.5)
)

(
{LFNoise0.ar(10)}.plot(1)
)
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
	oscVel=100,nVel=100,modVel=100
    ;

    // variables
    var osc,noz,nozPostF,snd,pitchMod,nozEnv,numClaps,oscFreeSelf,wn1,wn2,clapFrequency,decayer;

    // convert to seconds from milliseconds
    oscAtk=DC.kr(oscAtk/1000);
    oscDcy=DC.kr(oscDcy/1000);
    nEnvAtk=DC.kr(nEnvAtk/1000);
    nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
    level=DC.kr(level);
	oscFreq=oscFreq-10;
	// add logistic curve to the mix
	mix=DC.kr(100/(1+(2.7182**((50-mix)/8))));

    // white noise generators (expensive)
    wn1=WhiteNoise.ar();
    wn2=WhiteNoise.ar();
    clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
    // determine who should free
    oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

    // define pitch modulation1
    pitchMod=Select.ar(modMode,[
		Decay.ar(Impulse.ar(0.0001),(1/(1.5*modRate))), // decay
        SinOsc.ar(-1*modRate), // sine
		Lag.ar(LFNoise0.ar(4*modRate),1/(4*modRate)), // random
    ]);

    // mix in the the pitch mod
	oscFreq=((oscFreq).cpsmidi+((pitchMod*modAmt).midicps*LinLin.kr(modVel,0,200,4.0,0)));

	oscFreq=Select.kr(modMode,[oscFreq*0.9,oscFreq,oscFreq]);

    // define the oscillator
    osc=Select.ar(oscWave,[
        SinOsc.ar(oscFreq+5),
        LFTri.ar(oscFreq+5)*0.5,
        SawDPW.ar(oscFreq)*0.5,
    ]);
/*	osc=SelectX.ar((modMode>1)*(modAmt.abs/48),[
		osc,
		(osc/2+(LPF.ar(wn2,modRate*1.1)*0.025))*4,
	]);*/
	osc=Select.kr(modMode>1,[
		osc,
		SelectX.ar(oscDcy<0.3,[
			LPF.ar(wn2,modRate),
			osc,
		])
	]);


    // add oscillator envelope
	decayer=Select.kr(distAmt>50,[0.05,(distAmt-50)/50*0.3]);
	osc=osc*EnvGen.ar(Env.new([0,1,0.9,0],[oscAtk,oscDcy*decayer,oscDcy],[0,-2,-12]),doneAction:oscFreeSelf);

    // apply velocity
    osc=(osc*LinLin.kr(oscVel,0,200,2,0)).softclip;

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
        BBandPass.ar(noz,nFilFrq/2,Clip.kr(1/nFilQ,0.5,3)),
        BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
    ]);
    // special Q
    nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

    // apply envelope to noise
    noz=Splay.ar(nozPostF*nozEnv);

	// apply velocities
    noz=(noz*LinLin.kr(nVel,0,200,2,0)).softclip;

    // apply distortion
	osc=SineShaper.ar(osc,1.0,1+(10/(1+(2.7182**((50-distAmt)/8))))).softclip;

    // mix oscillator and noise
    snd=SelectX.ar(mix/100,[noz*nLevel.dbamp,osc*oscLevel]);

    // apply eq after distortion
    snd=BPeakEQ.ar(snd,eQFreq,0.5,eQGain/2);

	snd=HPF.ar(snd,20);

    // level
	Out.ar(0, snd*level.dbamp*0.2);
}).add;
)
// Name: "SC SD Zeroto9 Short"
(
Synth("nanotonic",[
\distAmt,0,
\eQFreq,347.20036170848,
\eQGain,0,
\level,-0.30718544541392,
\mix,100,
\modAmt,0,
\modMode,0,
\modRate,1,
\modVel,100,
\nEnvAtk,2.8132563237796,
\nEnvDcy,96.878974640252,
\nEnvMod,1,
\nFilFrq,1764.3930506381,
\nFilMod,1,
\nFilQ,0.70710682858809,
\nStereo,0,
\nVel,36.000001430511,
\oscAtk,0.50616508836824,
\oscDcy,410.5226701979,
\oscFreq,260,
\oscVel,29.324200749397,
\oscWave,1,
]);
)
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

    // white noise generators (expensive)
    wn1=WhiteNoise.ar();
    wn2=WhiteNoise.ar();
    clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
    // determine who should free
    oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

    // define pitch modulation1
    pitchMod=Select.ar(modMode,[
		Decay.ar(Impulse.ar(0.0001),(1/modRate)), // decay
        SinOsc.ar(-1*modRate), // sine
		Lag.ar(LFNoise0.ar(4*modRate),1/(4*modRate)), // random
    ]);

    // mix in the the pitch mod
	oscFreq=((oscFreq).cpsmidi+((pitchMod*modAmt).midicps*LinLin.kr(modVel,0,200,4.0,0)));

    // define the oscillator
    osc=Select.ar(oscWave,[
        SinOsc.ar(oscFreq+5),
        LFTri.ar(oscFreq+5)*0.5,
        SawDPW.ar(oscFreq)*0.5,
    ]);
	osc=SelectX.ar((modMode>1)*(modAmt.abs/48),[
		osc,
		LPF.ar(wn2,modRate),
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
        BBandPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
        BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
    ]);
    // special Q
    nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

    // apply envelope to noise
    noz=Splay.ar(nozPostF*nozEnv);

	// apply velocities
    noz=(noz*LinLin.kr(nVel,0,200,2,0)).softclip;

    // apply distortion
	osc=SineShaper.ar(osc,1.0,1+(distAmt/10)).softclip;

    // mix oscillator and noise
    snd=SelectX.ar(mix/100,[noz*nLevel.dbamp,osc*oscLevel]);

    // apply eq after distortion
    snd=BPeakEQ.ar(snd,eQFreq,0.5,eQGain);

    snd=HPF.ar(snd,10);

    // level
    Out.ar(0, snd*level.dbamp*0.5);
}).add;
)

// Name: "SC BD Toxyk"
(
Synth("nanotonic",[
\distAmt,26.06406211853,
\eQFreq,80.661909666463,
\eQGain,13.046813011169,
\level,-10.49999870510493,
\mix,88.153877258301,
\modAmt,33.019509360458,
\modMode,0,
\modRate,4.0523291566457,
\nEnvAtk,2.1977363693469,
\nEnvDcy,1104.977660676,
\nEnvMod,0,
\nFilFrq,392.00617432122,
\nFilMod,0,
\nFilQ,1.463421337541,
\nStereo,1,
\nVel,40.751650929451,
\oscAtk,0.0,
\oscDcy,726.5732892423,
\oscFreq,48.060961337325,
\oscVel,38.951644301414,
\oscWave,0,
]);
)
// Name: "RD GSn"
(
Synth("nanotonic",[
\distAmt,0.0,
\eQFreq,59.707651558903,
\eQGain,-40.0,
\level,6.9716982228375,
\mix,60.833332061768,
\modAmt,30.521283094447,
\modMode,2,
\modRate,7571.3339922825,
\nEnvAtk,0.0,
\nEnvDcy,316.22776601684,
\nEnvMod,0,
\nFilFrq,245.05603577429,
\nFilMod,2,
\nFilQ,148.37726231182,
\nStereo,1,
\nVel,0.0,
\oscAtk,0.0,
\oscDcy,68.739970893796,
\oscFreq,266.70428643266,
\oscVel,0.0,
\oscWave,0,
]);
)
// Name: "LV HH HT"
(
Synth("nanotonic",[
\distAmt,0.0,
\eQFreq,111.80335896926,
\eQGain,-36.059684753418,
\level,0.0,
\mix,0.0,
\modAmt,0.0,
\modMode,0,
\modRate,2.8301886792453,
\nEnvAtk,1.7076868541052,
\nEnvDcy,55.259588908601,
\nEnvMod,0,
\nFilFrq,7447.9779098801,
\nFilMod,2,
\nFilQ,0.70710500896458,
\nStereo,0,
\nVel,46.002021431923,
\oscAtk,0.0,
\oscDcy,10.0,
\oscFreq,20.0,
\oscVel,0.0,
\oscWave,0,
]);
)
// Name: "VT-808 CP"
(
Synth("nanotonic",[
\distAmt,0.3341009169817,
\eQFreq,825,
\eQGain,18.736724853516,
\level,0.0,
\mix,8.7251434326172,
\modAmt,38.0,
\modMode,2,
\modRate,1995.78120095,
\nEnvAtk,34.526091455159,
\nEnvDcy,199.32752864136,
\nEnvMod,2,
\nFilFrq,1000,
\nFilMod,1,
\nFilQ,0.05636863434079,
\nStereo,0,
\nVel,25.0,
\oscAtk,0.44352287396344,
\oscDcy,202.7378979947,
\oscFreq,259.9589879903,
\oscVel,25.0,
\oscWave,0,
]);
)
// Name: "SC BD Schmack"
(
Synth("nanotonic",[
\distAmt,80.160900354385,
\eQFreq,479.95005904163,
\eQGain,-40.0,
\level,2.9318368442652,
\mix,82.0,
\modAmt,36.902400567627,
\modMode,0,
\modRate,2.9422735268749,
\nEnvAtk,26.68178034809,
\nEnvDcy,181.96632325047,
\nEnvMod,0,
\nFilFrq,69.347309273301,
\nFilMod,0,
\nFilQ,2.5692426661038,
\nStereo,0,
\nVel,32.99999833107,
\oscAtk,0.0,
\oscDcy,859.40729368463,
\oscFreq,44.774409098621,
\oscVel,65.99999666214,
\oscWave,1,
]);
)
// Name: "SC SD Zeroto9 Short"
(
Synth("nanotonic",[
\distAmt,18.17979067564,
\eQFreq,694.40079396646,
\eQGain,-17.492098808289,
\level,7.0444581469742,
\mix,67.398193359375,
\modAmt,19.722088125357,
\modMode,0,
\modRate,5.2224226206798,
\nEnvAtk,0.0,
\nEnvDcy,114.19789555739,
\nEnvMod,1,
\nFilFrq,1764.3930506381,
\nFilMod,1,
\nFilQ,1.4096421051983,
\nStereo,1,
\nVel,100.0,
\oscAtk,0.0,
\oscDcy,119.99570374329,
\oscFreq,97.962603166918,
\oscVel,26.324200630188,
\oscWave,1,
]);
)
// Name: "LV HH HT 2"
(
Synth("nanotonic",[
\distAmt,0.0,
\eQFreq,111.80335896926,
\eQGain,-36.059684753418,
\level,0.0,
\mix,0.0,
\modAmt,0.0,
\modMode,0,
\modRate,2.8301886792453,
\nEnvAtk,0.0,
\nEnvDcy,258.8188153688,
\nEnvMod,0,
\nFilFrq,7447.9779098801,
\nFilMod,2,
\nFilQ,0.70710500896458,
\nStereo,1,
\nVel,46.002021431923,
\oscAtk,0.0,
\oscDcy,19.158122536198,
\oscFreq,20.0,
\oscVel,0.0,
\oscWave,0,
]);
)
// Name: "VT-K55 Tom Low"
(
Synth("nanotonic",[
\distAmt,6.6050708293915,
\eQFreq,40.963648646408,
\eQGain,-40.0,
\level,0.0,
\mix,85.114639282227,
\modAmt,2.2941263972371,
\modMode,0,
\modRate,1.3025102245623,
\nEnvAtk,5.2391506244795,
\nEnvDcy,313.58177894808,
\nEnvMod,1,
\nFilFrq,327.22092304425,
\nFilMod,0,
\nFilQ,1.1181320436858,
\nStereo,0,
\nVel,0.0,
\oscAtk,1.4000000090385,
\oscDcy,418.07695787332,
\oscFreq,129.23803254906,
\oscVel,0.0,
\oscWave,0,
]);
)
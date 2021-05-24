// Engine_Nanotonic

// Inherit methods from CroneEngine
Engine_Nanotonic : CroneEngine {

    // Nanotonic specific v0.1.0
    var synNanotonic;
    // Nanotonic ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Nanotonic specific v0.0.1
        synNanotonic=Array.new(maxSize:5);

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
    oscAtk=oscAtk/1000;
    oscDcy=oscDcy/1000;
    modRate=modRate/1000;
    nEnvAtk=nEnvAtk/1000;
    nEnvDcy=nEnvDcy/1000*1.4;
    level=level*1.5;

    // white noise generators (expensive)
    wn1=WhiteNoise.ar();
    wn2=WhiteNoise.ar();
    clickTrigger=Trig.ar(1,0.005);
    clapDuration=4311/(nEnvAtk+28.4)+11.44; // fit using matlab
    // determine who should free
    oscFreeSelf=Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]);
    
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
    numClaps=Select.kr((nEnvAtk>0.06),[
        2,
        Select.kr((nEnvAtk>0.15),[
            4,
            Select.kr((nEnvAtk>0.15),[
                8,
                16,
            ]);
        ]);
    ]);
    nozEnv=Select.kr(nEnvMod,[
        EnvGen.kr(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential),doneAction:(2-oscFreeSelf)),
        EnvGen.kr(Env.linen(nEnvAtk,0,nEnvDcy)),
// clap
// EnvGen.kr(Env.perc(0,4/clapFrequency,curve:[4,-4]),Impulse.kr(clapFrequency))*Trig.kr(1,nEnvAtk)+
EnvGen.kr(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential))
        (1-(LFPulse.kr(numClaps/nEnvAtk,0,0.45,-1,1)*Trig.ar(1,nEnvAtk)))*EnvGen.kr(Env.linen(0.0,nEnvAtk,nEnvDcy,curve:\cubed)),
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
}).add;

        context.server.sync;

        synNanotonic = Array.fill(3,{arg i;
            Synth("nanotonic", [\level,-100],target:context.xg);
        });

        context.server.sync;

        this.addCommand("nanotonic","fffffffffffffffffffi", { arg msg;
            // lua is sending 1-index
            if (synNanotonic[msg[20]-1].isRunning,{
                synNanotonic[msg[20]-1].free;
            });
            synNanotonic[msg[20]-1]=Synth("nanotonic",[
                \out,0,
                \distAmt, msg[1],
                \eQFreq, msg[2],
                \eQGain, msg[3],
                \level, msg[4],
                \mix, msg[5],
                \modAmt, msg[6],
                \modMode, msg[7],
                \modRate, msg[8],
                \nEnvAtk, msg[9],
                \nEnvDcy, msg[10],
                \nEnvMod, msg[11],
                \nFilFrq, msg[12],
                \nFilMod, msg[13],
                \nFilQ, msg[14],
                \nStereo, msg[15],
                \oscAtk, msg[16],
                \oscDcy, msg[17],
                \oscFreq, msg[18],
                \oscWave, msg[19],
            ], target:context.server);
        });
        // ^ Nanotonic specific

    }

    free {
        // Nanotonic Specific v0.0.1
        (0..3).do({arg i; synNanotonic[i].free});
        // ^ Nanotonic specific
    }
}

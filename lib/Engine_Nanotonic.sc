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
            Out.ar(0, snd*level.dbamp*0.05);
        }).add;

        context.server.sync;

        synNanotonic = Array.fill(5,{arg i;
            Synth("nanotonic", [\level,-100],target:context.xg);
        });

        context.server.sync;

        this.addCommand("nanotonic","fffffffffffffffffffi", { arg msg;
            // lua is sending 1-index
            synNanotonic[msg[20]-1].free;
            // if (synNanotonic[msg[20]-1].isRunning,{
            // });
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
        (0..5).do({arg i; synNanotonic[i].free});
        // ^ Nanotonic specific
    }
}

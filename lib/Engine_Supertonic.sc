// Engine_Supertonic

// Inherit methods from CroneEngine
Engine_Supertonic : CroneEngine {

    // Supertonic specific v0.1.0
    var synSupertonic;
    var synVoice=0;
    var maxVoices=5;
    // Supertonic ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Supertonic specific v0.0.1
        // pitch modulation
        SynthDef("modMode0",{
            arg modRate,modAmt,modVel,vel,out;
            var pitchMod;
            vel=LinLin.kr(vel,0,128,0,2);
            pitchMod=Decay.ar(Impulse.ar(0.0001),(1/(2*modRate)));
            pitchMod=pitchMod*modAmt/2*(LinLin.kr(modVel,0,200,2,0)*vel);
            Out.ar(out,pitchMod);
        }).add;
        SynthDef("modMode1",{
            arg modRate,modAmt,modVel,vel,out;
            var pitchMod;
            pitchMod=SinOsc.ar(-1*modRate);
            pitchMod=pitchMod*modAmt/2*(LinLin.kr(modVel,0,200,2,0)*vel);
            Out.ar(out,pitchMod);
        }).add;
        SynthDef("modMode2",{
            arg modRate,modAmt,modVel,vel,out;
            var pitchMod;
            pitchMod=Lag.ar(LFNoise0.ar(4*modRate),1/(4*modRate));
            pitchMod=pitchMod*modAmt/2*(LinLin.kr(modVel,0,200,2,0)*vel);
            Out.ar(out,pitchMod);
        }).add;
        // oscillators
        SynthDef("oscWave0",{
            arg oscFreq,out,pitchModIn;
            oscFreq=oscFreq+5;
            oscFreq=((oscFreq).cpsmidi+In.ar(pitchModIn,1)).midicps;
            Out.ar(out,SinOsc.ar(oscFreq));
        }).add;
        SynthDef("oscWave1",{
            arg oscFreq,out,pitchModIn;
            oscFreq=oscFreq+5;
            oscFreq=((oscFreq).cpsmidi+In.ar(pitchModIn,1)).midicps;
            Out.ar(out,LFTri.ar(oscFreq,mul:0.5));
        }).add;
        SynthDef("oscWave2",{
            arg oscFreq,out,pitchModIn;
            oscFreq=oscFreq+5;
            oscFreq=((oscFreq).cpsmidi+In.ar(pitchModIn,1)).midicps;
            Out.ar(out,SawDPW.ar(oscFreq,mul:0.5));
        }).add;
        // noise generation
        SynthDef("nStereo0",{
            arg out;
            var snd = WhiteNoise.ar();
            Out.ar(out,[snd,snd]);
        }).add;
        SynthDef("nStereo1",{
            arg out;
            Out.ar(out,[WhiteNoise.ar(),WhiteNoise.ar()]);
        }).add;
        // noise envelope
        SynthDef("nEnvMod0",{
            arg out,nEnvAtk,nEnvDcy,distAmt;
            var decayer,env;
            nEnvAtk=DC.kr(nEnvAtk/1000);
            nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
            env=EnvGen.ar(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential));
            Out.ar(out,env);
        }).add;
        SynthDef("nEnvMod1",{
            arg out,nEnvAtk,nEnvDcy,distAmt;
            var decayer,env;
            nEnvAtk=DC.kr(nEnvAtk/1000);
            nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
            decayer=SelectX.kr(distAmt/100,[0.05,distAmt/100*0.3]);
            env=EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[nEnvAtk,nEnvDcy*decayer,nEnvDcy*(1-decayer)],\linear));
            Out.ar(out,env);
        }).add;
        SynthDef("nEnvMod2",{
            arg out,nEnvAtk,nEnvDcy,distAmt;
            var clapFrequency,env;
            nEnvAtk=DC.kr(nEnvAtk/1000);
            nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
            clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
            env=Decay.ar(Impulse.ar(clapFrequency),1/clapFrequency,0.85,0.15)*Trig.ar(1,nEnvAtk+0.001)+
            EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential));
            Out.ar(out,env);
        }).add;
        // base
        SynthDef("supertonicBase", {
            arg out,modModeIn,oscWaveIn,nStereoIn,nEnvModIn,
            mix=50,level=(-5),distAmt=2,
            eQFreq=632.4,eQGain=(-20),
            oscAtk=0,oscDcy=500,
            oscWave=0,oscFreq=54,
            modMode=0,modRate=400,modAmt=18,
            nEnvAtk=26,nEnvDcy=200,
            nFilFrq=1000,nFilQ=2.5,
            nFilMod=0,nEnvMod=0,nStereo=1,
            oscLevel=1,nLevel=1,
            oscVel=100,nVel=100,modVel=100,
            fx_lowpass_freq=20000,fx_lowpass_rq=1,
            vel=64;

            // variables
            var osc,noz,nozPostF,snd,nozEnv,decayer;

            // convert to seconds from milliseconds
            vel=LinLin.kr(vel,0,128,0,2);
            oscAtk=DC.kr(oscAtk/1000);
            oscDcy=DC.kr(oscDcy/1000);
            nEnvAtk=DC.kr(nEnvAtk/1000);
            nEnvDcy=DC.kr(nEnvDcy/1000*1.4);
            level=DC.kr(level);
            mix=DC.kr(100/(1+(2.7182**((50-mix)/8)))); // logistic curve

            // define the oscillator
            osc=In.ar(oscWaveIn,1);

            // special addition
            osc=Select.ar(modMode>1,[
                osc,
                SelectX.ar(oscDcy<0.1,[
                    LPF.ar(In.ar(nStereoIn,2),modRate),
                    osc,
                ])
            ]);

            // add oscillator envelope
            decayer=SelectX.kr(distAmt/100,[0.05,distAmt/100*0.3]);
            osc=osc*EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[oscAtk,oscDcy*decayer,oscDcy],\exponential));

            // apply velocity
            osc=(osc*LinLin.kr(oscVel,0,200,1,0)*vel).softclip;

            // generate noise
            noz=In.ar(nStereoIn,2);

            // define noise envelope
            nozEnv=In.ar(nEnvModIn,1);

            // apply noise filter
            nozPostF=Select.ar(nFilMod,[
                BLowPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
                BBandPass.ar(noz,nFilFrq,Clip.kr(2/nFilQ,0.1,6)),
                BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
            ]);
            // special Q
            nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

            // apply envelope to noise
            noz=Splay.ar(nozPostF*nozEnv);

            // apply velocities
            noz=(noz*LinLin.kr(nVel,0,200,1,0)*vel).softclip;

            // mix oscillator and noise
            snd=SelectX.ar(mix/100*2,[
                noz*0.5,
                noz*2,
                osc*1
            ]);

            // apply distortion
            snd=SineShaper.ar(snd,1.0,1+(10/(1+(2.7182**((50-distAmt)/8))))).softclip;

            // apply eq after distortion
            snd=BPeakEQ.ar(snd,eQFreq,1,eQGain/2);

            snd=HPF.ar(snd,20);

            snd=snd*level.dbamp*0.2;
            // free self if its quiet or if it runs out
            FreeSelf.kr(TDelay.kr(DC.kr(1),ArrayMax.kr([oscAtk+oscDcy,nEnvAtk+nEnvDcy])));
            DetectSilence.ar(snd,0.0001,doneAction:2);

            // apply some global fx
            snd=RLPF.ar(snd,fx_lowpass_freq,fx_lowpass_rq);

            // level
            Out.ar(0, snd);
        }).add;

        context.server.sync;

        synSupertonic = Array.fill(maxVoices,{arg i;
            Synth("supertonic", [\level,-100],target:context.xg);
        });

        context.server.sync;

        this.addCommand("supertonic","ffffffffffffffffffffffffi", { arg msg;
            var oscWaveBus=Bus.audio(s,1);
            var nStereoBus=Bus.audio(s,2);
            var nEnvModBus=Bus.audio(s,1);
            var synthGroup=Group.new(context.server);
            var nEnvMod=msg[11];
            var oscWave=msg[19];
            var modMode=msg[7];
            var nStereo=msg[15];
            var modModeSyn,oscWaveSyn,nStereoSyn,nEnvModSyn;

            // voice allocation
            synVoice=synVoice+1;
            if (synVoice>(maxVoices-1),{synVoice=0});
            if (synSupertonic[synVoice].isRunning,{
                ("freeing "++synVoice).postln;
                synSupertonic[synVoice].free;
            });

            modModeSyn=Synth("modMode"++modMode.asInteger,[
                \out,pitchModBus,
                \modAmt,33.019509360458,
                \modRate,4.0523291566457,
                \modVel,35.558253526688,
                \vel,64,
            ],synthGroup);
            oscWaveSyn=Synth.after(modModeSyn,"oscWave"++oscWave.asInteger,[
                \oscFreq,48.060961337325,
                \out,oscWaveBus,
                \pitchModIn,pitchModBus,
            ],synthGroup);
            nStereoSyn=Synth.after(oscWaveSyn,"nStereo"++nStereo.asInteger,[
                \out,nStereoBus,
            ],synthGroup);
            nEnvModSyn=Synth.after(nStereoSyn,"nEnvMod"++nEnvMod.asInteger,[
                \out,nEnvModBus,
                \distAmt,34.064063429832,
                \nEnvAtk,2.1977363693469,
                \nEnvDcy,1104.977660676,
            ],synthGroup);
            synSupertonic[synVoice]=Synth.after(nEnvModSyn,"supertonicBase",[
                \oscWaveIn,oscWaveBus,
                \nStereoIn,nStereoBus,
                \nEnvModIn,nEnvModBus,
                \distAmt,94.064063429832,
                \eQFreq,80.661909666463,
                \eQGain,30.246815681458,
                \level,-5.1201522322287,
                \mix,88.153877258301,
                \modAmt,33.019509360458,
                \modRate,4.0523291566457,
                \modVel,35.558253526688,
                \modMode,0,
                \nEnvAtk,2.1977363693469,
                \nEnvDcy,1104.977660676,
                \nEnvMod,0,
                \nFilFrq,392.00617432122,
                \nFilMod,0,
                \nFilQ,1.463421337541,
                \nStereo,1,
                \nVel,40.751650929451,
                \oscAtk,0,
                \oscDcy,726.5732892423,
                \oscFreq,48.060961337325,
                \oscVel,38.951644301414,
                \oscWave,0,
                \vel,64,
            ],synthGroup).onFree({
                "freed".postln;
                synthGroup.free;
                pitchModBus.free;
                oscWaveBus.free;
                nStereoBus.free;
                nEnvModBus.free;
            });
            NodeWatcher.register(synSupertonic[synVoice]);
        });

        this.addCommand("supertonic_lpf","iff",{ arg msg;
            synSupertonic[msg[1]-1].set(
                \fx_lowpass_freq,msg[2],
                \fx_lowpass_rq,msg[3],
            );
        });
        // ^ Supertonic specific

    }

    free {
        // Supertonic Specific v0.0.1
        (0..maxVoices).do({arg i; synSupertonic[i].free});
        // ^ Supertonic specific
    }
}

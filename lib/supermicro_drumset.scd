// 2. define the sounds
(
~er = { | o = 1, p = 16 |(o / p * (0..p - 1)).floor.differentiate.asInteger.min(1)[0] = if (o <= 0) { 0 } { 1 };};

~kicksound={Synth("supermicro",[
\distAmt,34.064063429832,
\eQFreq,80.661909666463,
\eQGain,30.246815681458,
\level,-5.1201522322287,
\mix,88.153877258301,
\modAmt,33.019509360458,
\modMode,0,
\modRate,4.0523291566457,
\modVel,35.558253526688,
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
])};
~hhsound={Synth("supermicro",[
\distAmt,1.9999999552965,
\eQFreq,111.80335896926,
\eQGain,-36.059684753418,
\level,0,
\mix,0,
\modAmt,0,
\modMode,0,
\modRate,2.8301886792453,
\modVel,36.000001430511,
\nEnvAtk,1.7076868541052,
\nEnvDcy,90.509330260423,
\nEnvMod,0,
\nFilFrq,7447.9779098801,
\nFilMod,2,
\nFilQ,0.70710500896458,
\nStereo,0,
\nVel,43.002021312714,
\oscAtk,0,
\oscDcy,10,
\oscFreq,20,
\oscVel,40.999999642372,
\oscWave,0,
])};
~sdsound={Synth("supermicro",[
\distAmt,35.499998927116,
\eQFreq,59.707651558903,
\eQGain,-40,
\level,-4.9999159382834,
\mix,60.833332061768,
\modAmt,23.346161411536,
\modMode,2,
\modRate,12662.482988632,
\modVel,40.000000596046,
\nEnvAtk,0,
\nEnvDcy,439.39704746109,
\nEnvMod,0,
\nFilFrq,245.05603577429,
\nFilMod,2,
\nFilQ,148.37726231182,
\nStereo,0,
\nVel,40.999999642372,
\oscAtk,0,
\oscDcy,68.739970893796,
\oscFreq,251.73534018926,
\oscVel,33.000001311302,
\oscWave,0,
])};
~clapsound={Synth("supermicro",[
\distAmt,18.334101140499,
\eQFreq,981.49547151245,
\eQGain,28.736724853516,
\level,-6.1622793557187,
\mix,8.7251434326172,
\modAmt,-48,
\modMode,2,
\modRate,10995.78120095,
\modVel,27.000001072884,
\nEnvAtk,34.526091455159,
\nEnvDcy,199.32752864136,
\nEnvMod,2,
\nFilFrq,3571.0693697945,
\nFilMod,1,
\nFilQ,0.37636863434079,
\nStereo,0,
\nVel,25,
\oscAtk,0.44352287396344,
\oscDcy,1402.7378979947,
\oscFreq,2459.9589879903,
\oscVel,34.999999403954,
\oscWave,0,
])};
)


// 3. define the rhythms
(
~kick=~er.(0);
~kick=~er.(2).rotate(2);
~kick=~er.(3).rotate(2)+~er.(1);
~hh={~er.(4).rotate(2)+~er.(7)};
~hh={~er.(14).rotate(2)};
~sd={~er.(2)+~er.(rrand(5,6)).rotate(2)};
~sd=~er.(0);
~sd={~er.(2)+~er.(6).rotate(2)};
~sd=~er.(2).rotate(6);
~sd=~er.(2).rotate(6)+~er.(1).rotate(5);
~clap={~er.(5)+~er.(2).rotate(3)-~er.(4,16)};
~clap=~er.(2).rotate(4)+~er.(3).rotate(7);
~clap=~er.(0);
)

// 4. let it go!
(
x=~kicksound.(1);
y=~hhsound.(1);
z=~sdsound.(1);
w=~clapsound.(1);
t.stop;
t = Task({
    var bpm=120;
    var beats=16;
    inf.do({ arg i;
        ~rand56=rrand(5,6);
        if (~kick[i%beats]>0,{
            if (x.isPlaying,{
                x.free;
            });
            x=~kicksound.(1);
        });
        if (~hh.(1)[i%beats]>0,{
            if (y.isPlaying,{
                y.free;
            });
            y=~hhsound.(1);
        });
        if (~sd.(1)[i%beats]>0,{
            if (z.isPlaying,{
                z.free;
            });
            z=~sdsound.(1);
        });
        if (~clap.(1)[i%beats]>0,{
            if (w.isPlaying,{
                w.free;
            });
            w=~clapsound.(1);
        });
        (60/bpm/4).wait;
    });
}).play;
)


## supertonic

an introspective drum machine.

![Image](https://user-images.githubusercontent.com/6550035/120124212-22d3d680-c168-11eb-9b83-6d9b29303972.png)

the introspective drum machine looks into itself, and its own self-examination produces the rhythm.

### introspection

this drum machine introspects by looking at any of the currently playing drum sounds and generating a drum pattern for another sound based on its rhythm (e.g. a snare rhythm based on the kick pattern).

these generative rhythms are accomplished using [Google's "variational autoencoder" for drum performances](https://github.com/magenta/magenta/tree/master/magenta/models/music_vae). [their blog post](https://magenta.tensorflow.org/groovae) explains it best (and [their paper explains it better](https://arxiv.org/pdf/1803.05428.pdf)), but essentially they had professional drummers play and electronic drum-set for 12+ hours which was later used to feed a special kind of neural network. I used their model from this network and sampled it randomly to produce "new" drum rhythms (>~1,000,000 of them). then I created prior distributions for calculating bayesian probabilities for each instrument in this sampled dataset. the final result is a probability table that can generate a snare drum pattern based on a kick drum pattern, or generate a hihat pattern based on a snare drum pattern, etc. etc.


### sounds

the sounds for this drum machine come from a new engine which I call "supertonic" because it is a as-close-as-I-can port of the [microtonic VST by SonicCharge](https://soniccharge.com/microtonic). 

the act of porting is not straightforward and the experience itself was a motivation for this script - it helped me to learn how to use SuperCollider as I tried to match up sounds between the VST and SuperCollider using my ear. I learned there is a lot of beautiful magic in microtonic that makes it sounds wonderful, and I doubt I got half of the magic that's in the actual VST. looking at the resulting engine you might notice some weird equations that are supposed to be approximating this behavior.

### drummer in a box

so in the end, this script itself is a little drum machine in a box and a new drum machine engine for norns, a little like [cyrene](https://norns.community/authors/21echoes/cyrene), [hachi](https://norns.community/authors/pangrus/hachi), or [foulplay](https://norns.community/authors/justmat/foulplay). but with fewer features. its interesting to play with though, to see what does a AI generated drum loop sound like to perform with maybe? its surprisngly good sometimes.

### Requirements

- norns

### Documentation

all the parameters for the engine are in the `PARAM` menu, as well as preset loading.

on the main screen:

- K2 starts/stops
- K3 toggles hit
- E2 changes track (current is bright)
- E3 changes position in track

**introspection** 

introspection requires installing the prior table and `sqlite3. both of these can be installed by running this command in maiden:

```
os.execute("sudo apt install -y sqlite3; mkdir -p /home/we/dust/data/supertonic/; curl --progress-bar https://github.com/schollz/supertonic/releases/download/v1_ai/drum_ai_patterns.db > /home/we/dust/data/supertonic/drum_ai_patterns.db")
```

- K1+K3 generates new drum pattern based on highlighted pattern
- K1+E2 changes highlighted pattern
- K1+K2 generates new drum pattern based on first sixteen beats

**using your own microtonic presets**

if you have microtonic you can easily use your own microtonic preset. simply copy your microtonic preset file (something like `<name>.mtpreset`) and and save it as `/home/we/dust/data/supertonic/presets/`. you can then load this preset via the `PARAM > SUPERTONIC > preset` menu.

**converting microtonic presets for use with SuperCollider**

you can also use the engine directly with SuperCollider. the engine file is synced with a SuperCollider script, `lib/supertonic.scd`. an example drumset is in `lib/supertonic_drumset.scd`. you can easily get a SuperCollider file with your microtonic presets by running this lua script:

```
lua ~/dust/code/supertonic/lib/mtpreset2sc.lua /location/to/your/<name>.mtpreset ~/dust/data/supertonic/default.preset > presets.sc
```

**known bugs**

the supertonic engine is pretty cpu-intensive, so if you have 4-5 instruments all doing fast patterns (or fast tempo) you will hit cpu walls and hear crunching.

the pattern generation (k1+k3 or k1+k2) runs asynchronously but I've noticed that sometimes it might cause a little latency when using it while performing (generating patterns while playing).

## license 

mit 





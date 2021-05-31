## supertonic

a microtonic-based drum engine and AI-based drum machine.

![Image](https://user-images.githubusercontent.com/6550035/120124212-22d3d680-c168-11eb-9b83-6d9b29303972.png)

this script contains two musical aspirations:

1) generating new drum rhythms based on known rhythms
2) generating all drum sounds from a single engine

the first aspiration simply uses [Google's "variational autoencoder" for drum performances](https://github.com/magenta/magenta/tree/master/magenta/models/music_vae). [their blog post](https://magenta.tensorflow.org/groovae) explains it best (and [their paper explains it better](https://arxiv.org/pdf/1803.05428.pdf)), but essentially they had professional drummers play and electronic drum-set for 12+ hours which was later used to feed a special kind of neural network. I used their model from this network and sampled it randomly to produce "new" drum rhythms, and then I created prior distributions for each instrument in the set. so for example, this can be used ot generate a snare drum pattern based on a kick drum, or generate a hihat pattern based on a snare drum, etc. etc.

the second aspiration was to try out using a single engine for all the drum sounds (kick, snare, closed hat, open hat, clap). to do this I attempted to "port" the [microtonic VST by SonicCharge](https://soniccharge.com/microtonic). the act of porting is not straightforward and the experience itself was a big part of the aspiration - it helped me to learn how to use SuperCollider as I tried to match up sounds between the VST and SuperCollider using my ear. I learned there is a lot of beautiful magic in microtonic that makes it sounds wonderful, and I doubt I got half of the magic that's in the actual VST, but it turned out pretty close. a little example of the trials of porting include trying to find this strange non-linear relationship between the "attack time" and the "retrigger rate" to get the modulation for the noise envelope (which is important for the clap sound), I ended up plotting waveforms, measuring peak-to-peaks, and fitting a random nonlinear curve which "works":

![plotting spectrum](https://user-images.githubusercontent.com/6550035/120140273-0b5c1400-c18f-11eb-8d49-0c47e794b24b.png)


![fit](https://user-images.githubusercontent.com/6550035/120140271-0ac37d80-c18f-11eb-8cc5-9b350b9ef7d4.PNG)


so in the end, this script itself is a little drum machine in a box and a new drum machine engine for norns, a little like [cyrene](https://norns.community/authors/21echoes/cyrene), [hachi](https://norns.community/authors/pangrus/hachi), or [foulplay](https://norns.community/authors/justmat/foulplay). but moreso its an answer to a question - what does a AI generated drum loop sound like to perform with? 

### Requirements

- norns

### Documentation

all the parameters for the engine are in the `PARAM` menu.

on the main screen:

- E2 changes track (current is bright)
- E3 changes position in track
- K2 clears track
- K3 toggles hit

**AI add-on**

- K1+K3 generates new drum pattern based on highlighted pattern
- K1+E2 changes highlighted pattern
- K1+K2 generates new drum pattern based on first sixteen beats


using the AI requires installing the database (~100 mb) and also installing `sqlite3`. both of these can be installed by running this command in maiden:

```
os.execute("sudo apt install -y sqlite3; mkdir -p /home/we/dust/data/supertonic/; curl --progress-bar https://github.com/schollz/supertonic/releases/download/v1_ai/drum_ai_patterns.db > /home/we/dust/data/supertonic/drum_ai_patterns.db")
```


## license 

mit 





# Hell is Other Yourselves

A VR puzzle game where your future and past-self need to cooperate.

__NOTE__: This game is a big Work in Progress. The main point was to give a goal for the [lava game engine](https://github.com/Breush/lava-jai).

## Compile and run

The compilation (compiling game-engine and the game itself) should take less than 1 second.

```bash
git submodule update --init --recursive
jai src/first.jai
./bin/hioy
```

## Develop without a VR HMD (using the Monado runtime)

- Follow `remote` section from [here](https://monado.freedesktop.org/developing-with-monado.html).
- Run the program with the monado runtime forced.

```bash
monado-service&
monado-gui # connect with remote
XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json ./bin/hioy
```

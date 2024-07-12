# Cauldron

### Bringing Magik to Fish Shell 🪄🐟

If you've ever felt like you need a familiar when working in terminal, you've come to the right place!

### Installation

To install simply clone the repo then run the install script.

```shell
mkdir -p ~/.cauldron;
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron;
cd ~/.cauldron;
./install.fish;
```

### Re-Installation

If you had any issues with the installation and need to re-install, while preserving your configuration so far, you can run the following internal tool

```shell
./internal/__backup_cauldron_and_update.fish
```

### Updating

To update Cauldron, simply run:

```shell
cauldron --update
```

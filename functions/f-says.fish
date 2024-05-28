function f-says --wraps='cowsay -f $CAULDRON_FAMILIAR ' --description 'alias f-says=cowsay -f $CAULDRON_FAMILIAR '
    cowsay -f $CAULDRON_FAMILIAR $argv
end

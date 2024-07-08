function yarn+ --wraps='yarn set version stable; yarn; yarn upgrade-interactive' --description 'alias yarn+=yarn set version stable; yarn; yarn upgrade-interactive'
  yarn set version stable; yarn; yarn upgrade-interactive $argv
        
end

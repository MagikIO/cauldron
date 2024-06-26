function n+ --wraps='asdf local nodejs latest; corepack enable; asdf reshim nodejs; yarn set version stable;' --wraps='asdf local nodejs latest; corepack enable; asdf reshim nodejs; yarn set version stable' --wraps='asdf local nodejs latest; corepack enable; asdf reshim nodejs; yarn+' --description 'alias n+=asdf local nodejs latest; corepack enable; asdf reshim nodejs; yarn+'
  asdf local nodejs latest; corepack enable; asdf reshim nodejs; yarn+ $argv
        
end

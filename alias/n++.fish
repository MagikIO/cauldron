function n++ --wraps='asdf install nodejs latest' --wraps='asdf global nodejs latest; asdf install nodejs latest; corepack enable; asdf reshim nodejs' --description 'alias n++=asdf global nodejs latest; asdf install nodejs latest; corepack enable; asdf reshim nodejs'
  asdf global nodejs latest; asdf install nodejs latest; corepack enable; asdf reshim nodejs $argv
        
end

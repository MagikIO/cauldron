function underline --argument text
    set_color -u
    echo -n $text
    set_color normal
end

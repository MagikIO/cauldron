function bold --argument text
    set_color --bold
    echo -n $text
    set_color normal
end

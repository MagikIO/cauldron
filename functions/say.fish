function say -a message
    if type -q f-says
        f-says $message
    else if type -q print_separator
        print_separator $message
    else
        echo $message
    end
end

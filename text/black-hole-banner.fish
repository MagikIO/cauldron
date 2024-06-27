#!/usr/bin/env fish

function black-hole-banner --argument txt
banner $txt | tte blackhole --star-colors ffcc0d ff7326 ff194d bf2669 702a8c 049dbf --final-gradient-stops 8A008A 00D1FF FFFFFF --final-gradient-steps 12 --final-gradient-direction vertical
end

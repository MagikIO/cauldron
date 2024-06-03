function go
	set message_tips "Consuming the internet to get bigger" "Increasing my Power Levels" "Eating some bits.." "Ooops nearly choked on a bit"
  set_color purple
  echo $message_tips[(random 1 (count $message_tips))];
	sudo apt-get update | lolcat;
	wait;
	yes | sudo apt-get upgrade | lolcat;
	wait;
	yes | sudo apt-get autoremove | lolcat;
	wait;
	set_color blue;
	echo "All done with upgrading myself, let's check our your repo!"
	npm update | lolcat;
	wait;
	set_color pink;
	echo "All done, good luck with your code!"
	npm run dev
end

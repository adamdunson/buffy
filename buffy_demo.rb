require './buffy'
trap('SIGINT') { exit }
loop { p Buffy.getch }

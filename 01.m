# Initiation
clear

# General function
function next_state = general_markov (current_state, transition, n)
	if (nargin != 3)
		usage ("general_markov (current_state, transition, n)");
	endif
	next_state = current_state * transition ^ n;
endfunction

function next_day = forecast (n, today)
	next_day = general_markov (today, [.4 .4 .2; .3 .3 .4; .1 .6 .3], n);
endfunction

# Part A
n = 1
today = [0 1 0];
tomorrow = forecast(n, today);
display(tomorrow);

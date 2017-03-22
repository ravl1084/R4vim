if exists("g:disable_r_ftplugin")
	finish
endif

function SendR(cmd)
	call system("tmux -L vimR has-session -t RConsole")
	if v:shell_error
		echom "R is not running."
	else
		if a:cmd != ""
			call system("tmux -L vimR send-keys -t RConsole -l '".a:cmd."'")
			call system("tmux -L vimR send-keys -t RConsole Enter")
		else
			echom "Blank command not sent to R."
		endif
	endif
endfunction

function StartR()
	call system("tmux -L vimR has-session -t RConsole")
	if v:shell_error
		if g:R_term == "konsole"
			call system("konsole -e tmux -L vimR new-session -s RConsole 'R'")
		endif
	else
		echom "R is already running."
	endif
endfunction

function StopR()
	call system("tmux -L vimR has-session -t RConsole")
	if v:shell_error
		echom "R is not running."
	else
		let choice = confirm("Save R workspace?", "&yes\n&no\n&cancel")
		call system("tmux -L vimR send-keys -t RConsole -l 'q()'")
		call system("tmux -L vimR send-keys -t RConsole Enter")
		if choice == 1
			call system("tmux -L vimR send-keys -t RConsole -l y")
			call system("tmux -L vimR send-keys -t RConsole Enter")
		elseif choice == 2
			call system("tmux -L vimR send-keys -t RConsole -l n")
			call system("tmux -L vimR send-keys -t RConsole Enter")
		else
			call system("tmux -L vimR send-keys -t RConsole -l c")
			call system("tmux -L vimR send-keys -t RConsole Enter")
		endif
	endif
endfunction

nnoremap <buffer> <localleader>rs :call StartR()<cr>
nnoremap <buffer> <localleader>rx :call StopR()<cr>

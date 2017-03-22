if exists("g:disable_r_ftplugin")
	finish
endif

function StartR()
	call system("tmux -L vimR has-session -t RConsole")
	if v:shell_error
		if g:R_term == "konsole"
			call system("konsole -e tmux -L vimR new-session -s RConsole 'R'")
		endif
	endif
endfunction

function StopR()
	call system("tmux -L vimR has-session -t RConsole")
	if v:shell_error
		echom 'R not running'
	else
		let choice = confirm("Save R workspace?", "&yes\n&no\n&cancel")
		call system("tmux -L vimR send-keys -t RConsole -l 'q()'")
		call system("tmux -L vimR send-keys -t RConsole Enter")
		if choice == 1
			call system("tmux -L vimR send-keys -t RConsole -l y")
		elseif choice == 2
			call system("tmux -L vimR send-keys -t RConsole -l n")
		else
			call system("tmux -L vimR send-keys -t RConsole -l c")
		endif
		call system("tmux -L vimR send-keys -t RConsole Enter")

	endif
	"call system("tmux -L vimR send-keys -t RConsole -l 'q()'")
	"call system("tmux -L vimR send-keys -t RConsole Enter")
endfunction

"Mappings
nnoremap <buffer> <localleader>rs :call StartR()<cr>
nnoremap <buffer> <localleader>rx :call StopR()<cr>

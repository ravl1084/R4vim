" File: r.vim
" Author: Rene Vergara
" Description: Vim plugin to interact with R simply
" Last Modified: March 22, 2017

if exists('did_r_vim') || &cp || version < 700
	finish
endif
let did_r_vim = 1

function IsRUp()
	call system("tmux -L vimR has-session -t RConsole")
	return v:shell_error
endfunction

function SendR(cmd)
	if IsRUp()
		echohl Error
		echom "R is not running."
		echohl None
	else
		if a:cmd != ""
			call system("tmux -L vimR send-keys -t RConsole -l '".a:cmd."'")
			call system("tmux -L vimR send-keys -t RConsole Enter")
		else
			echohl WarningMsg
			echom "Blank command not sent to R."
			echohl None
		endif
	endif
	call RbufferRefresh(tmpfile)
endfunction

function SendLineToR()
	execute "normal! _vg_\"byj"
	call SendR(@b)
endfunction

function SendChunkToR(chunk)
	let chlist=split(a:chunk, "\v\n")
	for chline in chlist
		call SendR(chline)
	endfor
endfunction

function RbufferRefresh(tmpfile)
	normal! ggdG
	call read tmpfile
endfunction

function RbufferOpen(tmpfile)
	let buffer_name = fnameescape(a:tmpfile)

	let bufsplit = bufwinnr('^' . buffer_name . '$')

	if bufsplit < 0
		silent! execute 'botright new '. buffer_name
	else
		silent! execute bufsplit . 'wincmd w'
	endif

	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber

	silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
	silent! execute 'nnoremap <silent> <buffer> <localleader>r :call RbufferRefresh(''' . a:tmpfile . ''')<cr>'
endfunction

function StartR()
	if IsRUp()
		if g:R_term == "konsole"
			call system("konsole -e tmux -L vimR new-session -s RConsole 'R'")
		else
			call system("xterm -e tmux -L vimR new-session -s RConsole 'R'")
		endif
		if IsRUp()
			echom "R started successfully"
			sleep 2000m
			let tmpfile = tempname()
			let initcmd = "sink(\"".tmpfile."\", append=TRUE, split=TRUE)"
			call SendR(initcmd)
			call RbufferOpen(tmpfile)
			call RbufferRefresh(tmpfile)

			silent! redraw
		else
			echohl Error
			echom "R did not start properly"
			echohl None
		endif
	else
		echohl WarningMsg
		echom "R is already running."
		echohl None
	endif
endfunction

function StopR()
	if IsRUp()
		echohl Error
		echom "R is not running."
		echohl None
	else
		let choice = confirm("Save R workspace?", "&yes\n&no\n&cancel")
		call SendR("q()")
		if choice == 1
			call SendR("y")
		elseif choice == 2
			call SendR("n")
		else
			call SendR("c")
		endif
	endif
endfunction

"Mappings
nnoremap <buffer> <silent><localleader>rs :call StartR()<cr>
nnoremap <buffer> <silent><localleader>rx :call StopR()<cr>
nnoremap <buffer> <silent><localleader>l :call SendLineToR()<cr>
vnoremap <buffer> <silent><localleader>l :call SendChunkToR(@*)<cr>

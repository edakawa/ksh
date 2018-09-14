#!/bin/ksh
#
# $Id: pcmd.sh,v 1.2 2018/09/14 15:21:11 hajime Exp $
#
# pcmd.sh - show your permitted commands by /etc/doas.conf
# Hajime Edakawa <hajime.edakawa@gmail.com>
# Public Domain
#
# How to use:
# 		$ set -A complete_doas -- $(pcmd.sh)
#

function pcmd {
	local _user=$(id -un) _file=/etc/doas.conf _line _flg _id _cmd _cmds \
	    _lists _item

	while read _line; do
		_line=${_line%%#*}
		if [[ $_line = @(permit)* ]]; then
			_line=${_line#* }
			[[ $_line = @(nopass|persist)* ]] && _line=${_line#* }
			[[ $_line = @(keepenv)* ]]        && _line=${_line#* }
			[[ $_line = @(setenv)* ]]         && _line=${_line#*\} }

			_flg=false
			_id=${_line%% *}
			[[ $_id = :* ]] && _flg=true; _id=${_id#:}
			_line=${_line#* }
			[[ $_line = @(as)* ]] && _line=${_line#as * }

			if [[ $_line = @(cmd)* ]]; then
				_line=${_line#* }
				[[ ${_line#* } = @(args)* ]] && \
				    _line=${_line%%args*}
				_cmd=$_line
				if [[ $_flg -eq false ]]; then
					[[ $_id = $_user ]] && \
					    _cmds[${#_cmds[*]}]=$_cmd
				else
					[[ $_id = @(0|[1-9]*([0-9])) ]]
					_lists=$(( $? == true ? $(id -G) : \
					    $(groups) ))
				fi
				for _item in $_lists; do
					[[ $_id = $_item ]] && \
					    _cmds[${#_cmds[*]}]=$_cmd && break
				done
			fi
		fi
	done <$_file
	echo ${_cmds[*]}
}

[[ -f /etc/doas.conf ]] || exit 1
[[ $# -ne 0 ]] && echo "usage: ${0##*/}" >&2 && exit 1

pcmd

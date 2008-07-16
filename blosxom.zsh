#!/usr/bin/env zsh
# vim:ft=zsh:

# array とかはそのまま関数に渡せない?
# あと array のなかに array もいれられない?
# っぽいので文字列として渡していちいちパース
# (q) とか (qq) とか (z) とかつかいまくる
# (qq) は空文字列でも安全

title="bloszom.zsh"

typeset -a pathinfo
: ${(A)pathinfo::=${(s:/:)PATH_INFO}}

flavour=${(M)pathinfo[$#pathinfo-1]%.*}
if [[ $flavour == "" ]]; then
	flavour=".html"
fi

function template () {
	template=$(<$1)
	typeset -A variables
	variables=()
	: ${(AA)variables::=${(z)*[2,-1]}}
	for k in ${(k)variables}; do
	#	echo "$k: $variables[$k]"
		pat=#{$k}
		sub=${(Q)variables[$k]}
		template=${template//$pat/$sub}
	done
	echo $template
}

template "head$flavour" title ${(qq)title} home ${(qq)SCRIPT_NAME}

typeset -a entries
entries=()

zmodload zsh/stat
zmodload zsh/datetime

# (^Om) で更新順にソート
for f in data/**/*.txt(^Om); do
	typeset -A entry
	stat -H st +mtime $f
	strftime -s date "%Y-%m-%d %H:%M:%S" $st[mtime]
	content=$(<$f)
	: ${(A)content::=${(f)content}}
	title=$content[0]
	body=${(F)content[2,-1]}
	entry=(
		title ${(qq)title}
		time  $st[mtime]
		date  ${(q)date}
		body  ${(qq)body}
		path  ${(q)f}
		name  ${(q)${f##data}%%.*}

		home ${(qq)SCRIPT_NAME}
	)

	entries+=${(kv)entry}
done

if [[ $#pathinfo > 0 && "$PATH_INFO" != "" ]]; then
	pathinfo[$#pathinfo-1] = ${pathinfo[$#pathinfo-1]%.*}
	if [[ pathinfo[$#pathinfo-1] == "index" ]]; then
		pathinfo[$#pathinfo-1] =
	fi
	for ((i = 1; i < $#entries; i += 1)); do
		typeset -A entry
		: ${(AA)entry::=${(z)entries[$i]}}
		if [[ ${(M)entry[name]#$PATH_INFO} == ""  ]]; then
			entries[$i]="path 0"
		fi
	done
fi

for ((i = 1; i < $#entries; i += 1)); do
	typeset -A entry
	: ${(AA)entry::=${(z)entries[$i]}}
	if [[ $entry[path] != "0" ]]; then
		template "story$flavour" ${(kv)entry}
	fi
done

template "foot$flavour" version ${(qq)ZSH_VERSION}


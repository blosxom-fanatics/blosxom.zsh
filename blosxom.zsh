#!/usr/bin/zsh
# vim:ft=sh:

# array とかはそのまま関数に渡せない?
# あと array のなかに array もいれられない?
# っぽいので文字列として渡していちいちパース
# (q) とか (qq) とか (z) とかつかいまくる
# (qq) は空文字列でも安全

echo "Content-Type: text/html"
echo

function template () {
	template=$(cat $1)
	typeset -A variables
	variables=()
	: ${(AA)variables::=${(z)*[2,-1]}}
	for k in ${(k)variables}; do
		#echo "$k: $variables[$k]"
		pat=#{$k}
		sub=${(Q)variables[$k]}
		template=${template//$pat/$sub}
	done
	echo $template
}

template "head.html" title bbb home aaaaa

typeset -a entries
entries=()

zmodload zsh/stat
zmodload zsh/datetime

# (^Om) で更新順にソート
for f in data/**/*.txt(^Om); do
	typeset -A entry
	stat -H st +mtime $f
	strftime -s date "%Y-%m-%d %H:%M:%S" $st[mtime]
	content=$(cat $f)
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
	)
	entries+=${(kv)entry}
done

# TODO: フィルタリング

for ((i = 0; i < $#entries; i += 1)); do
	typeset -A entry
	entry=$entries[$i]
	template "story.html" ${(kv)entry}
done

version=`zsh --version`
template "foot.html" version ${(qq)version}


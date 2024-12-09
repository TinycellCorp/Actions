#!/usr/bin/env bash

xcodeproj_dir="$1"
exec_script="$2"

if [ ! -d "$xcodeproj_dir" ]; then
	echo "require xcode project directory as first argument"
	echo "ex: init.sh /path/to/xcodeproj /path/to/exec_script"
	exit 1
fi

echo "xcodeproj_dir: $xcodeproj_dir"

scripts_dir="$(pwd)/$(dirname "$0")"
echo "scripts_dir: $scripts_dir"

if [ ! -f "$scripts_dir/$exec_script" ]; then
	echo "require executable script as second argument"
	echo "ex: init.sh /path/to/xcodeproj /init.sh/same/dir/exec_script"
	exit 1
fi

ignores=(
	"$(basename "$0")"
	".DS_Store"
)

files=$(find "$scripts_dir" -type f)
for file in $files; do
	if [[ ${ignores[*]} =~ $(basename "$file") ]]; then
		continue
	fi
	to="${file//"$scripts_dir"/$xcodeproj_dir}"
	mkdir -p "$(dirname "$to")" && cp -rf "$file" "$to"
	echo "copying $file to $to"
done

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	export SESSION_TYPE=remote/ssh
fi

cd "$xcodeproj_dir" && exec "./$exec_script"

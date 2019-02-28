source "$basedir/scripts/functions.sh"
decompiledir="$workdir/Minecraft/$minecraftversion/forge"
# replace for now
decompiledir="$workdir/Minecraft/$minecraftversion/spigot"
        #echo "Copying $base to $target"
        cp "$base" "$target" || exit 1
function importLibrary {
    group=$1
    lib=$2
    prefix=$3
    shift 3
    for file in "$@"; do
        file="$prefix/$file"
        target="$workdir/Spigot/Spigot-Server/src/main/java/${file}"
        targetdir=$(dirname "$target")
        mkdir -p "${targetdir}"
        base="$workdir/Minecraft/$minecraftversion/libraries/${group}/${lib}/$file"
        if [ ! -f "$base" ]; then
            echo "Missing $base"
            exit 1
        fi
        export MODLOG="$MODLOG  Imported $file from $lib\n";
        sed 's/\r$//' "$base" > "$target" || exit 1
    done
}


files=$(cat "$basedir/Spigot-Server-Patches/"* | grep "+++ b/src/main/java/net/minecraft/server/" | sort | uniq | sed 's/\+\+\+ b\/src\/main\/java\/net\/minecraft\/server\///g' | sed 's/.java//g')

nonnms=$(grep -R "new file mode" -B 1 "$basedir/Spigot-Server-Patches/" | grep -v "new file mode" | grep -oE "net\/minecraft\/server\/.*.java" | grep -oE "[A-Za-z]+?.java$" --color=none | sed 's/.java//g')
function containsElement {
	local e
	for e in "${@:2}"; do
		[[ "$e" == "$1" ]] && return 0;
	done
	return 1
}
set +e
for f in $files; do
	containsElement "$f" ${nonnms[@]}
	if [ "$?" == "1" ]; then
		if [ ! -f "$workdir/Spigot/Spigot-Server/src/main/java/net/minecraft/server/$f.java" ]; then
			if [ ! -f "$decompiledir/$nms/$f.java" ]; then
				echo "$(color 1 31) ERROR!!! Missing NMS$(color 1 34) $f $(colorend)";
			else
				import $f
			fi
		fi
	fi
done

########################################################
########################################################
########################################################
#                   NMS IMPORTS
# Temporarily add new NMS dev imports here before you run paper patch
# but after you have paper rb'd your changes, remove the line from this file before committing.
# we do not need any lines added to this file for NMS

# import FileName



########################################################
########################################################
########################################################
#              LIBRARY IMPORTS
# These must always be mapped manually, no automatic stuff
#
#             # group    # lib          # prefix               # many files

# dont forget \ at end of each line but last
importLibrary com.mojang authlib com/mojang/authlib yggdrasil/YggdrasilGameProfileRepository.java

########################################################
########################################################
########################################################
set -e
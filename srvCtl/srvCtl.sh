#!/bin/bash
# Install Games Servers
# Global default if no games specified
games="sdtd pz ns2 rust ark"

declare -A dependencies
dependencies=(
        [rust]=" tmux mailutils postfix curl lib32gcc1 libstdc++6 libstdc++6:i386"
         [ns2]=" tmux mailutils postfix curl lib32gcc1 libstdc++6 libstdc++6:i386 speex:i386 libtbb2"
         [sdtd]=" tmux mailutils postfix curl lib32gcc1 libstdc++6 libstdc++6:i386 telnet expect"
         [pz]=" tmux mailutils postfix curl lib32gcc1 libstdc++6 libstdc++6:i386 openjdk-7-jre"
         [ark]=" tmux mailutils postfix curl lib32gcc1 libstdc++6 libstdc++6:i386"
)
function replace {
	sed -i "0,/${1}/s,${1},${2}," "$3"
}
function installGame {

        local user="$1"'server'
#	if sudo id -u "$user" &>/dev/null ; then echo "Game Server '$1' already installed" ; return 0 ; fi
        sudo useradd -m "$user"
        local homeDir='/home/'"$user"

#	local installURL='http://gameservermanagers.com/dl'
#        sudo wget "$installURL"'/'"$user" -O  "$homeDir"'/'"$user"

        local installScript="$homeDir"'/'"$user"
        sudo chown -R "$user" "$installScript"
        sudo chmod +x "$installScript"

        steamUsername="$(head -1 ./steaminfo )"
        steamPassword="$(tail -1 ./steaminfo )"
#	replace 'username' "$steamUsername" "$installScript"
#	replace 'password' "$steamPassword" "$installScript"
	sudo su - "$user" -c "$installScript install" 

	replace 'off' 'on' "$installScript"
	replace 'off' 'on' "$installScript"
	replace 'off' 'on' "$installScript"
#	replace 'email@example.com' '' "$installScript"
#	replace '0.0.0.0' '' "$installScript"
#	sudo su - "$user" -c "$installScript start"
#	sudo su - "$user" -c "$installScript stop"
}
function installSrv {
	local allDependencies=""
        for game in $1 ; do
        	allDependencies+="${dependencies["$game"]}"
        done
	echo "installing dependancies: '$allDependencies'" && sudo apt-get install -y $allDependencies &>/dev/null

        for game in $1 ; do
		echo "installing $game"
		installGame "$game"
        done
        echo "All done!"
}
#	installSrv "$games"
for game in $games ; do
		user="$game"'server'
		homeDir='/home/'"$user"
		installScript="$homeDir"'/'"$user"
		sudo su - "$user" -c "$installScript start"
done
: '
if [ "$#" -eq '0' ] ; then 
	installSrv "$games"
elif [ "$#" -ne '0' ] ; then 
	case "$1"
		'install')  
			shift
			installSrv "$1"
		;;
		'start')
			shift
			for game in $1 ; do
				local user="$game"'server'
				local homeDir='/home/'"$user"
				local installScript="$homeDir"'/'"$user"
				sudo su - "$user" -c "$installScript start"
			done
		;;
		'stop')
			shift
			for game in $1 ; do
				local user="$game"'server'
				local homeDir='/home/'"$user"
				local installScript="$homeDir"'/'"$user"
				sudo su - "$user" -c "$installScript stop"
			done

		;;
		'restart')
			shift
			for game in $1 ; do
				local user="$game"'server'
				local homeDir='/home/'"$user"
				local installScript="$homeDir"'/'"$user"
			done
		;;
	esac
fi
'

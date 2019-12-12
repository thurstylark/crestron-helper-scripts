cn-progload() {
	local addr="$1"
	local project="$2"
	local ext="${project##*.}"
	# Add a zero in front of the 3rd arg
	local slot="0${3}"
	# expand only to the last 2 digits of $slot 
	slot="${slot: -2}"


	case $ext in 

		vtz)
			if [[ ! -z $slot ]]; then
				echo "==NOTICE== Ignoring slot number for touchpanel project..."
			fi
			printf 'put %q' "$project" | cnsftp $addr:display
			cnssh $addr projectload
			;;

		lpz)
			if [[ -z $slot ]]; then
				echo "==NOTICE== No target program slot defined. Assuming Slot 01..."
				slot=01
			fi
			printf 'put %q' "$project" | cnsftp $addr:Program$slot
			cnssh $addr progload -p:$slot
			;;

		*)
			echo "Error: Bad file type. Currently only supports vtz and lpz projects."
			;;
	esac
}

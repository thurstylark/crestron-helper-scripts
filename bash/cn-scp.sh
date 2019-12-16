cn-scp() {

	shopt -q extglob; local extglob_set=$?
	if ((extglob_set)); then
		echo "cn-scp: extglob must be set for this function to work properly."
		return 1
	fi
	local source="$1"
	local dest="$2"
	local sep=":"
	local host sourcefile destfile


	if [[ -z $source ]]; then
		echo "Error: No source provided"
		return 1
	elif [[ -z $dest ]]; then
		echo "Error: No destination provided"
		return 1
	fi


# Host determination:
	local loopcount=0
	for i in "$source" "$dest"; do
		case "$i" in 
			# Will match if $sep exists in string once
			*@("$sep")* )
				# Check if $host is unset
				if [[ -z $host ]]; then
					host="${i%%:*}"
					sourcefile="${source#*:}"
					destfile="${dest#*:}"
					# If this is the first run of the loop, the remote is the source
					if [[ "$loopcount" == 0 ]]; then
						operation="get"
					# If this is the second run of the loop, the remote is the dest
					elif [[ "$loopcount" == 1 ]]; then
						operation="put"
					# If this is anything other than the first or second loop, GTFO
					else
						echo "Error: Loop counting error."
						return 1
					fi
					continue
				else
					echo "Error: Remote path for *both* source and destination is not supported."
					return 1
				fi
				;;
			*)
				((loopcount++))
				continue
				;;
		esac
		((loopcount++))
	done
# END: Host determination


	printf '%q %q %q' "$operation" "$sourcefile" "$destfile" | cnsftp "$host"

}

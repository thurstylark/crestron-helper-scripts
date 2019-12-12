cn-fwupd() {
	local addr="$1"
	local puf="$2"
	local ext="${puf##*.}"

	case $ext in

		zip)
			printf 'put %q firmware/update.zip' "$puf" | cnsftp $addr
			cnssh $addr pushupdate FULL
			;;
		puf)
			printf 'put %q firmware/update.puf' "$puf" | cnsftp $addr
			cnssh $addr puf
			;;
		*)
			echo "Error: Bad file type. Currently, only'.zip' and '.puf' file types are supported."
			;;
	esac
}

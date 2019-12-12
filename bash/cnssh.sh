cnssh() {
	# Usage: cnssh <ip address> [command]
	local uname="Crestron"
	local pass=""
	local addr="$1"
	shift
	local cmd="$@" 

	sshpass -p "$pass" ssh \
		-o StrictHostKeyChecking=no\
		-o GlobalKnownHostsFile=/dev/null\
		-o UserKnownHostsFile=/dev/null\
		-o LogLevel=ERROR\
		-o User="$uname"\
		"$addr" "$cmd"
}

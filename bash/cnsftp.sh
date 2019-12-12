cnsftp() {
	local uname="Crestron"
	local pass=""
	local cmd="$@" 

	sshpass -p "$pass" sftp \
		-o StrictHostKeyChecking=no\
		-o GlobalKnownHostsFile=/dev/null\
		-o UserKnownHostsFile=/dev/null\
		-o LogLevel=ERROR\
		-o User="$uname" \
		"$cmd"
}

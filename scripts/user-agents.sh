#!/bin/sh

# replace pattern in file
function replace_in_file() {
        # escape slashes
        pattern=$(echo "$2" | sed "s/\//\\\\\//g")
        replace=$(echo "$3" | sed "s/\//\\\\\//g")
	replace=$(echo "$replace" | sed "s/\\ /\\\\ /g")
        sed -i "s/$pattern/$replace/g" "$1"
}

BLACKLIST="$(curl https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list)"
DATA=""
IFS=$'\n'
for ua in $BLACKLIST ; do
	DATA="${DATA}~*(?:\b)${ua}\(?:\b) yes;\n"
done
cp /opt/confs/map-user-agent.conf /etc/nginx/map-user-agent.conf
replace_in_file "/etc/nginx/map-user-agent.conf" "%BLOCK_USER_AGENT%" "$DATA"
if [ -f /run/nginx/nginx.pid ] ; then
	/usr/sbin/nginx -s reload
fi
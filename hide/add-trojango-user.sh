#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

MYIP=$(curl -sS ipv4.icanhazip.com)


clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi
tr="$(cat ~/log-install.txt | grep -w "Trojan WS " | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		user_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

		if [[ ${user_EXISTS} -ge '1' ]]; then
clear
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Bug Host/SNI : " sni

read -p "Password (UUID) : " uuid
read -p "Expired (Ex. 1 days): " masaaktif
exp=`date -d "$masaaktif" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

systemctl restart xray
trojanlink1="trojan://${uuid}@${domain}:${tr}?mode=gun&security=tls&type=grpc&serviceName=hidessh-trojan-grpc&sni=${sni}#${user}"
trojanlink="trojan://${uuid}@${domain}:${tr}?path=%2Fhidessh-trojan-ws&security=tls&host=${domain}&type=ws&sni=${sni}#${user}"

result=$(cat <<RESULT
{
 "remarks": "$user",
 "host": "$domain",
 "port": "$tr",
 "sni": "$sni",
 "key": "$user",
 "path": "/hidessh-trojan-ws",
 "linkWs": "$trojanlink",
 "linkGrpc": "$trojanlink1",
 "exp": "$exp"
}
RESULT
)

resultb64=$(  base64 -w 0 <<< $result)

clear

echo $resultb64
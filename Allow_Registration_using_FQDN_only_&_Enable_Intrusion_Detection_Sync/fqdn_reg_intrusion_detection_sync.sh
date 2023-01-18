#!/bin/bash
echo -e "Allow SIP Registrations via FQDN only"
echo -e "Written by: Kamil @ V4VoIP"
echo -e "FQDN specified is: $1"
echo -e "This script will overwrite existing custom firewall rules and the Firewall -> Advanced -> Advanced Configuration entries"
echo -e "Make sure that the FQDN you used is correct, otherwise, it will prevent legitimate extensions from registering to the server"

while true; do

read -p "Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] ) echo "Proceeding";
		break;;
	[nN] ) echo "Exiting";
		exit;;
	* ) echo "Invalid response";;
esac

done

sleep 1

echo "Step 1: Adding custom rules to the FreePBX Firewall"
cat > /etc/firewall-4.rules << EOF
-A fpbxreject -p udp --dport 5060:5161 -m state --state ESTABLISHED,RELATED -j ACCEPT
-A fpbxreject -p udp --dport 5060:5161 -m string --string "REGISTER sip:$1" --algo bm -j ACCEPT
-A fpbxreject -p udp --dport 5060:5161 -m string --string "REGISTER sip:" --algo bm -j DROP
-A fpbxreject -p udp --dport 5060:5161 -m string --string "INVITE sip:$1" --algo bm -j ACCEPT
-A fpbxreject -p udp --dport 5060:5161 -m string --string "INVITE sip:" --algo bm -j DROP
-A fpbxreject -p udp --dport 5060:5161 -m string --string "OPTIONS sip:$1" --algo bm -j ACCEPT
-A fpbxreject -p udp --dport 5060:5161 -m string --string "OPTIONS sip:" --algo bm -j DROP
-A fpbxreject -p tcp --dport 5060:5161 -m state --state ESTABLISHED,RELATED -j ACCEPT
-A fpbxreject -p tcp --dport 5060:5161 -m string --string "REGISTER sip:$1" --algo bm -j ACCEPT
-A fpbxreject -p tcp --dport 5060:5161 -m string --string "REGISTER sip:" --algo bm -j DROP
-A fpbxreject -p tcp --dport 5060:5161 -m string --string "INVITE sip:$1" --algo bm -j ACCEPT
-A fpbxreject -p tcp --dport 5060:5161 -m string --string "INVITE sip:" --algo bm -j DROP
-A fpbxreject -p tcp --dport 5060:5161 -m string --string "OPTIONS sip:$1" --algo bm -j ACCEPT
-A fpbxreject -p tcp --dport 5060:5161 -m string --string "OPTIONS sip:" --algo bm -j DROP
EOF

sleep 1

echo "Step 2: Setting permissions"

chown root:root /etc/firewall-4.rules
chmod 644 /etc/firewall-4.rules

sleep 1

echo "Step 3: Enabling Intrusion Detection Sync"

PBXDBUSER=$(php -r 'include("/etc/freepbx.conf"); echo $amp_conf["AMPDBUSER"];')
PBXDBPASS=$(php -r 'include("/etc/freepbx.conf"); echo $amp_conf["AMPDBPASS"];')
PBXDBNAME=$(php -r 'include("/etc/freepbx.conf"); echo $amp_conf["AMPDBNAME"];')

mysql -u "$PBXDBUSER" -p"$PBXDBPASS" -D "$PBXDBNAME" <<EOF
UPDATE kvstore_FreePBX_modules_Firewall SET val = '{"safemode":"enabled","masq":"enabled","lefilter":"enabled","customrules":"enabled","rejectpackets":"disabled","id_service":"enabled","id_sync_fw":"enabled","import_hosts":"enabled"}' WHERE kvstore_FreePBX_modules_Firewall.key = 'advancedsettings';
EOF

sleep 1

echo "Step 4: Restarting Firewall"
fwconsole firewall restart

sleep 10

echo "Success!"
echo "Please log-in to the FreePBX GUI, go to Firewall -> Intrusion Detection -> Under 'Import' Section, please select all zones"
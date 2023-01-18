# About:
This script restricts SIP/PJSIP registrations to the server by allowing packets that contains FQDN only, it also enables the new Intrusion Detection firewall sync, which allows to sync FreePBX firewall entries with fail2ban whitelist, allowing for more efficient management.\
Approach I have used allows to register to the server using IP address instead of FQDN only when the IP address is present in the FreePBX Firewall (allowing for SIP Trunk registration with providers who are using IP authentication).
You will see hits from scanners in your sngrep, showing that your server received the response but will not reply to it.\
The asterisk log file will only show registration attempts that are using FQDN.

# How to use:
> `git pull URL`\
`chmod +x fqdn_reg_intrusion_detection_sync.sh`\
`./fqdn_reg_intrusion_detection_sync.sh pbx.example.com`\
GUI -> Connectivity -> Firewall -> Intrusion Detection -> Import -> Select Desired Zones

# To be done:
- Import Intrusion Detection Zones via CLI or MySQL query (asked on FreePBX forum for advice as I'm not able to find the table responsible for this option)\
Forum URL requesting help: https://community.freepbx.org/t/intrusion-detection-sync-import-zones-via-cli-sql-query/87705
- Choice of Step 1 behavior - currently it allows connections using IP addresses only if they are present in the firewall, but there is also a possibility of restricting registration using IP address completely (you can replace the relevant portion of the script with below):
> -I INPUT -p udp --dport 5060:5161 -m string --string "INVITE sip:" --algo bm -j DROP\
-I INPUT -p udp --dport 5060:5161 -m string --string "INVITE sip:pbx.example.com" --algo bm -j fpbxfirewall\
-I INPUT -p udp --dport 5060:5161 -m string --string "OPTIONS sip:" --algo bm -j DROP\
-I INPUT -p udp --dport 5060:5161 -m string --string "OPTIONS sip:pbx.example.com" --algo bm -j fpbxfirewall\
-I INPUT -p udp --dport 5060:5161 -m string --string "REGISTER sip:" --algo bm -j DROP\
-I INPUT -p udp --dport 5060:5161 -m string --string "REGISTER sip:pbx.example.com" --algo bm -j fpbxfirewall\
-I INPUT -p udp --dport 5060:5161 -m state --state ESTABLISHED,RELATED -j fpbxfirewall\
-I INPUT -p tcp --dport 5060:5161 -m string --string "INVITE sip:" --algo bm -j DROP\
-I INPUT -p tcp --dport 5060:5161 -m string --string "INVITE sip:pbx.example.com" --algo bm -j fpbxfirewall\
-I INPUT -p tcp --dport 5060:5161 -m string --string "OPTIONS sip:" --algo bm -j DROP\
-I INPUT -p tcp --dport 5060:5161 -m string --string "OPTIONS sip:pbx.example.com" --algo bm -j fpbxfirewall\
-I INPUT -p tcp --dport 5060:5161 -m string --string "REGISTER sip:" --algo bm -j DROP\
-I INPUT -p tcp --dport 5060:5161 -m string --string "REGISTER sip:pbx.example.com" --algo bm -j fpbxfirewall\
-I INPUT -p tcp --dport 5060:5161 -m state --state ESTABLISHED,RELATED -j fpbxfirewall

# Sources:
https://taczanowski.net/securing-asterisk-sip-pbx-by-simple-iptables-rule-checking-if-the-domain-is-correct/\
https://community.freepbx.org/t/pbx-security/57441/9\
https://www.cyber-cottage.co.uk/?p=1028
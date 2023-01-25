#!/bin/sh
#
# Author: dsmaldone
# Released under GNU/GPL3 see here: https://www.gnu.org/licenses/gpl-3.0.en.html
# Source: https://github.com/dsmaldone/FreePBX/blob/master/vm-auto-delete.sh
#
# The scripr accepts 0 or 1 optional cli parameters.
# Optional Parameter: a comma separated value of all extension's voicemail to be deleted.
# If no argument is input, voicemails of all the existing extensions will be deleted.
# Usage: vm-auto-delete.sh [<ext1,ext2,ext3...>]
#
# Adjustable Parameters
# vm_dir: Voicemail directory root fullpath
# days: number of days to go back from today to start deleting messages
#
# Good to know
# logger: writes in the system log only in case of success
#
# Important: If the 'find' program it’s not found - Give Up!

narg=$#

days=180
vm_dir="/var/spool/asterisk/voicemail/"

regexp="^([0-9]*(,)?)+$"
find_loc=$(command -v find)
ftest=$?

if [ $ftest != 0 ]; then
        echo "Find Command not here! Giving Up!"
        exit 2
fi

if [ $narg -gt 1 ]; then
        echo "Invalid number of arguments. Script accepts 0 or 1 argument."
        echo "If no argument is input, voicemails of all the existing extensions will be deleted."
        echo "To select 1 or more than 1 ext use comma e.g. 100 or 200,300"
        exit 1
elif [ $narg -eq 0 ]; then
        logger $(date) - Executed Vociemail Cleanup: All voicemail messages older than $days days have been deleted
        $find_loc $vm_dir -name "msg*" -mtime +$days -type f -exec rm -rf {} \;
else
        if [[ $1 =~ $regexp ]]; then
                # Uncomment following line for debug
                # echo "found a match"
                for i in $(echo $1 | sed "s/,/ /g")
                do
                        curvm=$vm_dir/default/$i
                        if [ -d "$curvm" ]; then
                                logger $(date) - Checking Extension $i Voicemail
                                $find_loc $curvm -name "msg*" -mtime +$days -type f -exec rm -rf {} \;
                                # Uncomment following line for debug
                                # echo "checked $i"
                                vmchecked="${vmchecked}$i,"
                        fi
                done
                logger $(date) - Executed Voicemail Cleanup: All $vmchecked messages older than $days days have been deleted
        else
                echo "Invalid argument: allowed is comma separated extensions"
                exit 3
        fi
fi
exit 0
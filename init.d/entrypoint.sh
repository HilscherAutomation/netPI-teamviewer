#!/bin/bash +e
# catch signals as PID 1 in a container

# SIGNAL-handler
term_handler() {
   echo "terminating TeamViewer ..."
   teamviewer daemon stop

   echo "terminating agetty ..."
   kill "$AGETTYID"

   exit 143; # 128 + 15 -- SIGTERM
}

# on callback, stop all started processes in term_handler
trap 'kill ${!}; term_handler' SIGINT SIGKILL SIGTERM SIGQUIT SIGTSTP SIGSTOP SIGHUP

# set teamviewer password and start the TeamViewer Deamon
echo "setting TeamViewer password and start it ..."
if [ -z "$TEAMVIEWER_PASSWD" ]
then
# set a default password if there isn't any
teamviewer passwd 12354678
else
teamviewer passwd $TEAMVIEWER_PASSWD
fi

echo "waiting some seconds to let TeamView login and get a valid TeamViewer ID ..."
echo ''
sleep 10

# show/set TeamViewer license
if [ "$TEAMVIEWER_LICENSE" = "accept" ]; then
teamviewer license accept > /dev/null
echo '!!You have ACCEPTED the following terms and conditions!!'
echo '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
echo ''
else
echo '!!You have NOT ACCEPTED the following terms and conditions!!'
echo '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
echo ''
fi

echo 'TeamViewer® End-User License Agreement'
echo ''
echo 'This End-user License Agreement including its Annex ("EULA") applies to you and TeamViewer GmbH ("TeamViewer" or "We") for the licensing and use of our software, which includes the TeamViewer software and all versions, features, applications and modules thereto ("Software").'
echo 'This EULA also covers any associated media, printed materials and electronic documentation that we make available to you (with our Software and "Product"). Future releases of our Product may warrant amendments to this EULA.'
echo ''
echo 'BY CLICKING "ACCEPT", DOWNLOADING OR OTHERWISE USING OUR SOFTWARE, YOU AGREE TO ALL TERMS AND CONDITIONS OF THIS EULA. IF YOU DO NOT AGREE TO ANY OF THE TERMS OF THIS EULA, PLEASE IMMEDIATELY RETURN, DELETE OR DESTROY ALL COPIES OF OUR SOFTWARE IN YOUR POSSESSION.'
echo ''
echo 'You can review the full license agreement at http://www.teamviewer.com/link/?url=271351'
echo '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'

# show TeamViewer id
teamviewer info

# create a new session a start a login console on tty1
setsid agetty -a root tty1 linux &
AGETTYID="$!"

# wait forever not to exit the container
while true
do
  tail -f /dev/null & wait ${!}
done

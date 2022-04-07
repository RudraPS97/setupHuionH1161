#!/bin/bash
# Set Huion H1161 graphics tablet
# By Rudra Pratap Singh
# License: GNU GPLv3

pass1=1
pass2=2
welcome()
{
	kdialog --title "Welcome!" --msgbox "This will script will set keys on the Huion H1161 as soon as it is connected to the pc. " &>/dev/null;
}

getpassword()
{
	while ! [ $pass1 = $pass2 ]; do
		pass1=$(kdialog --password "Enter Sudoer's Password." 2>/dev/null)
		pass2=$(kdialog --password "Re-Type Sudoer's Password." 2>/dev/null)
	done;
}

createRules()
{
	touch temp1
	cat > temp1 << EOF
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="wacom.service"
EOF
	echo $pass1 | sudo -S cp temp1 /etc/udev/rules.d/99-wacom.rules
	rm temp1
}

createService()
{
	touch temp2
	cat > temp2 << EOF
[Unit]
Description=Configure my Wacom tablet
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=oneshot
ExecStart=/home/aurora/Documents/Scripts/Huion-h1161-Tablet-map-buttons.sh

[Install]
WantedBy=graphical-session.target
EOF

	echo $pass1 | sudo -S cp temp2 ~/.config/systemd/user/wacom.service
        rm temp2
}

createConfigScript()
{
	touch temp3
	cat > temp3 << EOF
#!/bin/bash
sleep 1
xsetwacom set "HUION Huion Tablet Pad pad" Button 1 "key +e"
xsetwacom set "HUION Huion Tablet Pad pad" Button 2 "key 0xffab"
xsetwacom set "HUION Huion Tablet Pad pad" Button 3 "key 0xffad"
xsetwacom set "HUION Huion Tablet Pad pad" Button 8 "key +ctrl z -ctrl"
xsetwacom set "HUION Huion Tablet Pad pad" Button 11 "key +v"
exit 0
EOF
	mkdir ~/Documents/Scripts/
	echo $pass1 | sudo -S cp temp3 ~/Documents/Scripts/Huion-h1161-Tablet-map-buttons.sh
	rm temp3
}

startServices()
{
	systemctl enable --user wacom.service
	systemctl start --user wacom.service
}


scriptComplere()
{
	kdialog --title "Done!" --msgbox "Huion H1161 has been set" &>/dev/null;
}

welcome
getpassword
createRules
createService
createConfigScript
startServices

#!/bin/bash

#variables
[ -z "$http_proxy" ] &&  . /etc/environment
gitdest="/home/admin"
url_nextjs='https://github.com/gz-bad-erzland-p3/projektarbeit.git'
commitid_local=$([ -d "/home/admin/nextjs" ] && cat "$gitdest/nextjs/.git/refs/heads/master")
commitid_online=$(git ls-remote "$url_nextjs" rev-parse HEAD | awk '{ print $1 }')

echo "${commitid_local} | ${commitid_online}" >~/test

result=0
if [[ "${commitid_local}" != "${commitid_online}" ]]; then
	echo "sind nicht gleich"
	git clone "$url_nextjs" "$gitdest/nextjstmp"
	#build tmp-image 
	podman build -t nextjstmp "$gitdest/nextjstmp/"
	
	result=$?
	if [ $result -eq 0 ]; then
		#Testcontainer wird gestartet
	    podman run -d --name nextjs-testctr localhost/nextjstmp &>/dev/null
		
		result=$? 
		if [ $result -eq 0 ]; then
			#wenn Fehlerfrei wird Container gestoppt und entfernt
			podman stop -t 3 nextjs-testctr &>/dev/null
		    podman rm -f nextjs-testctr &>/dev/null
			podman rmi nextjs-testctr &>/dev/null

			#aktueller Container wird über Dienst gestoppt
			systemctl --user stop container-nextjs-instance #&>/dev/null
			
			#aktuelles Image wird umbenannt nach bak
			podman rmi nextjsbak &>/dev/null
			podman tag nextjs nextjsbak && podman rmi nextjs
			podman tag nextjstmp nextjs && podman rmi nextjstmp
			
			rm -rf nextjs && mv nextjstmp nextjs
			
			result=$?
			if [ $result -eq 0 ]; then 
				podman create --name nextjs-instance --pod service_pod localhost/nextjs:latest
				
				podman start nextjs-instance
				
				podman generate systemd --new --name nextjs-instance > /home/admin/.config/systemd/user/container-nextjs-instance.service

				systemctl --user unmask container-nextjs-instance.service
				
				systemctl --user daemon-reload

				if [ "$(systemctl --user is-active container-nextjs-instance)" = "inactive" ]; then
					
					systemctl --user start container-nextjs-instance
					
					systemctl --user enable container-nextjs-instance
				
				fi
			fi
		fi
	fi
fi	

exit $result	



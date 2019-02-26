#!/bin/bash

clear
echo "#################"
echo $1 $2 $3 $4 $5
echo "#################"

nodeIp=$1
startingEndIp=$2
count=$3
ipPrefix=$4
hostPrefix=$5
argCount=$#
hostsFile="/etc/hosts"
hostName=$(hostname)

kubeletPlace=$(find /etc -name kubelet -exec bash -c  "echo {}" \;)
myIP=$1
echo "KUBELET_EXTRA_ARGS= --node-ip='${myIP}'" > ${kubeletPlace}
systemctl daemon-reload


# ["#{workerIP(i)}", "#$startingEndIp", "#$k8s_count", "#{ipPrefix()}"]
# 192.168.104.101 k8s-01


sed -i '/'${hostPrefix}'/d' $hostsFile
sed -i '/'${hostName}'/d' $hostsFile
sed -i '/'$ipPrefix'/d' $hostsFile
# Daha öne kullanılnmadıysa
# sed -i 's/plugins=.*/plugins=(git helm docker docker-compose docker-machine kubectl kube-ps1 zsh-autosuggestions zsh-syntax-highlighting vagrant vagrant-prompt)/' ~/.zshrc

echo -en '\n'  >> $hostsFile

for ((i=1;i<=$count;i++))
do
   newEndIp=$((startingEndIp+i))
#   echo $ipPrefix$newEndIp	$hostPrefix$i
   echo $ipPrefix$newEndIp	$hostPrefix$i >> $hostsFile
done


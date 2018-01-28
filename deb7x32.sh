#!/bin/bash

myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;

flag=0

echo

function create_user() {
#myip=`dig +short myip.opendns.com @resolver1.opendns.com`
clear
echo ""
echo ""
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $uname
exp="$(chage -l $uname | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$pass\n$pass\n"|passwd $uname &> /dev/null
echo -e ""
echo -e "Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·" 
echo -e " Informasi Akun Baru SSH Server Premium" 
echo -e "========================================="
echo -e "     Host/IP: $myip" 
echo -e "     Username: $uname" 
echo -e "     Password: $pass" 
echo -e "     Port Dropbear: 80, 443,109" 
echo -e "     Port OpenSSH: 22,143" 
echo -e "     Port Squid: 8000, 8080,3128" 
echo -e "     ------------------------------------" 
echo -e "     Aktif Sampai: $exp" 
echo -e "=========================================" 
echo -e "AKUN TELAH BERHASIL DIBUAT"
echo -e "            "
	myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
	#echo "Config OVPN (http://$myip/client.tar)" 
}

function renew_user() {
	echo "Kadaluarsa User: $uname Di Perbarui Sampai: $expdate";
	usermod -e $expdate $uname
}

function delete_user(){
	userdel $uname
}

function expired_users(){
	echo "---------------------------------"
echo "BIL  USERNAME          EXPIRED "
echo "---------------------------------"
count=1
	cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
	totalaccounts=`cat /tmp/expirelist.txt | wc -l`
	for((i=1; i<=$totalaccounts; i++ )); do
	tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
		username=`echo $tuserval | cut -f1 -d:`
		userexp=`echo $tuserval | cut -f2 -d:`
		userexpireinseconds=$(( $userexp * 86400 ))
		todaystime=`date +%s`
		expired="$(chage -l $username | grep "Account expires" | awk -F": " '{print $2}')"
		if [ $userexpireinseconds -lt $todaystime ] ; then
			printf "%-4s %-15s %-10s %-3s\n" "$count." "$username" "$expired"
			count=$((count+1))
		fi
	done
	rm /tmp/expirelist.txt
}

function not_expired_users(){
    cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
    totalaccounts=`cat /tmp/expirelist.txt | wc -l`
    for((i=1; i<=$totalaccounts; i++ )); do
        tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
        username=`echo $tuserval | cut -f1 -d:`
        userexp=`echo $tuserval | cut -f2 -d:`
        userexpireinseconds=$(( $userexp * 86400 ))
        todaystime=`date +%s`
        if [ $userexpireinseconds -gt $todaystime ] ; then
            echo $username
        fi
    done
	rm /tmp/expirelist.txt
}

function monssh2(){
echo "-------------------------------------------------------------"
echo " Date-Time    |    PID   |    User Name    |     Dari IP "
echo "-------------------------------------------------------------"
data=( `ps aux | grep -i dropbear | awk '{print $2}'`);

echo "=================[ Checking Dropbear login ]================="
echo "-------------------------------------------------------------"
for PID in "${data[@]}"
do
	#echo "check $PID";
	NUM=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l`;
	USER=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk -F" " '{print $10}'`;
	IP=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk -F" " '{print $12}'`;
	waktu=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk -F" " '{print $1,$2,$3}'`;
	if [ $NUM -eq 1 ]; then
		echo "$waktu - $PID - $USER - $IP";
	fi
done


echo "-------------------------------------------------------------"
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

echo "==================[ Checking OpenSSH login ]================="
echo "-------------------------------------------------------------"
for PID in "${data[@]}"
do
        #echo "check $PID";
		NUM=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | wc -l`;
		USER=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $9}'`;
		IP=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $11}'`;
		waktu=`cat /var/log/auth.log | grep -i sshd | grep -i "Accepted password for" | grep "sshd\[$PID\]" | awk '{print $1,$2,$3}'`;
        if [ $NUM -eq 1 ]; then
                echo "$waktu - $PID - $USER - $IP";
        fi
done

echo "-------------------------------------------------------------"
echo -e "==============[ User Monitor Dropbear & OpenSSH]============="
}

function used_data(){
	myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`
	myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`
	ifconfig $myint | grep "RX bytes" | sed -e 's/ *RX [a-z:0-9]*/Received: /g' | sed -e 's/TX [a-z:0-9]*/\nTransfered: /g'
}

function bench-network2(){
wget freevps.us/downloads/bench.sh -O - -o /dev/null|bash
echo -e "Sekian...!!!"
}

function user-list(){
echo "--------------------------------------------------"
echo "BIL  USERNAME        STATUS       EXP DATE   "
echo "--------------------------------------------------"
C=1
ON=0
OFF=0
while read mumetndase
do
        AKUN="$(echo $mumetndase | cut -d: -f1)"
        ID="$(echo $mumetndase | grep -v nobody | cut -d: -f3)"
        exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
        online="$(cat /etc/openvpn/log.log | grep -Eom 1 $AKUN | grep -Eom 1 $AKUN)"
        if [[ $ID -ge 500 ]]; then
        if [[ -z $online ]]; then
        printf "%-4s %-15s %-10s %-3s\n" "$C." "$AKUN" "ONLINE" "$exp"
        ON=$((ON+1))
        else
        printf "%-4s %-15s %-10s %-3s\n" "$C." "$AKUN" "OFFLINE" "$exp"
        OFF=$((OFF+1))
        fi
        C=$((C+1))
        fi
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
done < /etc/passwd
echo "--------------------------------------------------"
echo " ONLINE : $ON     OFFLINE : $OFF     TOTAL USER : $JUMLAH "
echo "--------------------------------------------------"
}

clear
# Removing existing bench.log 
rm -rf $HOME/bench.log 
# Reading out system information... 
# Reading CPU model 
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' ) 
# Reading amount of CPU cores 
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo ) 
# Reading CPU frequency in MHz 
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' ) 
# Reading total memory in MB 
tram=$( free -m | awk 'NR==2 {print $2}' ) 
# Reading Swap in MB 
vram=$( free -m | awk 'NR==4 {print $2}' ) 
# Reading system uptime 
up=$( uptime | awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }' | sed 's/^[ \t]*//;s/[ \t]*$//' ) 
# Reading operating system and version (simple, didn't filter the strings at the end...) 
opsy=$( cat /etc/issue.net | awk 'NR==1 {print}' ) # Operating System & Version 
arch=$( uname -m ) # Architecture 
lbit=$( getconf LONG_BIT ) # Architecture in Bit 
hn=$( hostname ) # Hostname 
kern=$( uname -r ) 
# Date of benchmark 
bdates=$( date )
# Output of results 
echo "Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·"
echo "System Info VPS Server ITA" | tee -a $HOME/bench.log 
echo "-----------" | tee -a $HOME/bench.log 
echo "Hostname  : $hn" | tee -a $HOME/bench.log 
echo "OS        : $opsy" | tee -a $HOME/bench.log 
echo "Arch      : $arch ($lbit Bit)" | tee -a $HOME/bench.log 
echo "Kernel    : $kern" | tee -a $HOME/bench.log 
echo "Processor : $cname" | tee -a $HOME/bench.log 
echo "CPU Cores : $cores" | tee -a $HOME/bench.log 
echo "Frequency : $freq MHz" | tee -a $HOME/bench.log 
echo "Uptime    : $up" | tee -a $HOME/bench.log 
echo "Memory    : $tram MB" | tee -a $HOME/bench.log 
echo "Swap      : $vram MB" | tee -a $HOME/bench.log 
echo "Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â· CYBER_NET ENCRYPTION Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·Ð“Â·"
PS3='Input options Number & click Enter: '
options=("Buat User" "Perbarui User" "Hapus User" "Semua User" "User Belum Kadaluarsa" "User Sudah Kadaluarsa" "Restart Server" "Ganti Password User" "Ganti Password VPS" "Used Data By Users" "bench-network" "Ram Status" "Bersihkan cache ram" "Monitor Multi Login" "Ganti Port OpenVPN" "Ganti Port Dropbear" "Ganti Port Squid3" "Speedtest" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Buat User")
            read -p "Enter username: " uname
            read -p "Enter password: " pass
            read -p "Kadaluarsa (Berapa Hari): " masaaktif
	    create_user
	    break
            ;;
        "Perbarui User")
            read -p "Enter username yg di perbarui: " uname
            read -p "Aktif sampai tanggal Thn-Bln-Hr(YYYY-MM-DD): " expdate
            renew_user
            break
            ;;
        "Hapus User")
            read -p "Ketik user yang akan di hapus: " uname
            delete_user
            break
            ;;		
		"Semua User")
            user-list
            break
            ;;
		"User Belum Kadaluarsa")
			not_expired_users
			break
			;;
		"User Sudah Kadaluarsa")
			expired_users
			break
			;;		
		"Restart Server")
			reboot
			break
			;;
		"Ganti Password User")
		read -p "Ketik user yang akan di ganti passwordnya: " uname
		passwd $uname
		break
		;;
		"Ganti Password VPS")
			passwd
			break
			;;
		"Used Data By Users")
			used_data
 			break
			;;
			"bench-network")
			bench-network2
			break
			;;
			"Ram Status")
			free -h | grep -v + > /tmp/ramcache
			cat /tmp/ramcache | grep -v "Swap"
			break
			;;
			"Bersihkan cache ram")
		echo 3 > /proc/sys/vm/drop_caches
			break
			;;
			"Monitor Multi Login")
			monssh2
                break
	          ;;
		"Ganti Port OpenVPN")	
            echo "Silahkan ganti port OpenVPN anda lalu klik enter?"
            read -p "Port: " -e -i 55 PORT
            sed -i "s/port [0-9]*/port $PORT/" /etc/openvpn/1194.conf
            service openvpn restart
            echo "OpenVPN Updated Port: $PORT"
			break
			;;
		"Ganti Port Dropbear")	
            echo "Silahkan ganti port Dropbear anda lalu klik enter?"
	    echo "Port dropbear tidak boleh sama dengan port openVPN/openSSH/squid3 !!!"
            echo "Port1: 443" 
	    read -p "Port2: " -e -i 109 PORT
	    #read -p "Port3: " -e -i 143 PORT3
            sed -i "s/DROPBEAR_PORT=[0-9]*/DROPBEAR_PORT=$PORT/g" /etc/default/dropbear
	    sed -i 's/DROPBEAR_EXTRA_ARGS="-p [0-9]*"/DROPBEAR_EXTRA_ARGS="-p 443"/g' /etc/default/dropbear	
    service dropbear restart
            echo "Dropbear Updated Port2 : $PORT"
	    #echo "Dropbear Updated : Port2 $PORT2"
	    #echo "Dropbear Updated : Port3 $PORT3"
			break
			;;
        "Ganti Port Squid3")	
            echo "Silahkan ganti port Squid3 anda lalu klik enter?"
            echo "Port 1 dan Port 2 tidak boleh sama !!!"
	    echo "Isi dengan angka tidak boleh huruf !!!"
	    read -p "Port 1: " -e -i 8080 PORT1
	    read -p "Port 2: " -e -i 3128 PORT2
            sed -i "s/http_port [0-9]*\nhttp_port [0-9]*/http_port $PORT1\nhttp_port $PORT2/g" /etc/squid3/squid.conf
            service squid3 restart
            echo "Squid3 Updated Port1: $PORT1"
	    echo "Squid3 Updated Port2: $PORT2"
			break
			;;
			"Speedtest")
			python speedtest.py --share
			break		
			;;
		"Quit")
		
		break
		;;
	 
        *) echo invalid option;;
    esac
done

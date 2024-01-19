#!/bin/bash
#vypina a zapina syslog
#service rsyslog stop
# je treba nainstalovat "sshpass" -- Nemam slov -- chapete ze je to uz nekolik let ?  Myslim tak q1/2016 ?? :(   sshpass -y).
##
#Semka nejaky login ktery je pouzit na RB 
LOGIN=test
##
#heslo  v pripade ze neni pouzit klic v nasem pripade pro test pouzijeme neprustrelne heslo "admin123"  
PASSWORD="admin123" #semka ve full textu kdz by byl problem jde udelat do souboru PF primo heslo a pak to cte odsud  "pf"
#PASSWORD=$(awk 'NR == 1' pf) #semka kdyz by se cetlo heslo ze souboru jinak zakomentovat ! "pf"
##
#semka definice SSHd portu na jakem je dostupny na protistrane
SSHPORT=22
##
##FTP doporucuji nepouzivat napriklad pro tvorbu RoMON Backupu rozjebe to identifikatory !!! 
#FTPPORT=21021  #nn FTP nepouzivat rozmrda to vse 
###
IPLISTFILE=/home/mart/tux/mikrotik-fw-upgrade/mikrotik-fw-upgrade-list #tady se zadavaji IP do kterejch sype pak mikrotik data
###
##definice slozky kde jsou ulozene data jako  FW,Nastaveni,Scripty,Aktualizace atd ...
SUBDIR=/home/mart/tux/mikrotik-fw-upgrade/fw/mipsbe 
##src slozky pto ostatni platformy tilera,mips,powerpc atd ...
##SUBDIR=/home/mart/tux/mikrotik-fw-upgrade/fw/XXXXXX
##
#proste zakladni log proslo/neproslo nebo chyba 
LOGFILE=/home/mart/tux/mikrotik-fw-upgrade/mikrotik-fw-upgrade.log #proste log
index=0
while read line ; do
IPLIST[$index]="$line"
index=$(($index+1))
done < $IPLISTFILE
echo ${iplist[@]}
for (( i=0; i<${#IPLIST[@]}; i++ ));
do
HOSTIP=${IPLIST[$i]}
echo  >>$LOGFILE
echo $HOSTIP `date +%Y%m%d%H%M%S` >>$LOGFILE
##ftp varianta
##wget -N -nv -P $SUBDIR/$HOSTIP ftp://$HOSTIP:$FTPPORT/* --ftp-user=$LOGIN --ftp-password=$PASSWORD >>$LOGFILE  2>>$LOGFILE  #ftp off
##
#
##pozor kouknete nejdrive zda se na pixlu na proitistrane opravdu spojite, definujte si na obou stranach algoritmus pro komunikaci na SSH (jako stary vzor treba  ssh -oHostKeyAlgorithms=+ssh-dss root@192.168.1.1 -- myslim ze je to do zlomoveho 6.45.2 !! )
##
#pouziti s klicem nejlepsi zpusob !! -- zde je example cesta kde je ulozeny routerOS ktery se ma kopirovat -- pokud budete mit vice platforem schovejte to za promenne.
sshpass -p $PASSWORD scp -r /home/mart/tux/mikrotik-fw-upgrade/mipsbe/* $SSHPORT $LOGIN@$HOSTIP:/ >>$LOGFILE 2>>$LOGFILE 
#
#pripojime se znova a rebootneme RB kvuli aktualizace. Novej konekt je proto ze vetsinou to nechceme povysit hned. Zauvazujte tedy i na tom ze to rozdelite do vice scriptu at to nemusite vzdy zakomentovat :)  
#
###rozdeleno do 2 scriptu ne vzdy je vhodne ten RB restartovat hned po instalaci RouterOS 
##sshpass -p  ssh $LOGIN@$HOSTIP -p $SSHPORT -o StrictHostKeyChecking=no ':execute {/system reboot}' >>$LOGFILE  2>>$LOGFILE
##
##
done
#rsyslog restart 
##service rsyslog restart
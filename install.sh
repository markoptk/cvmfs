#!/bin/bash
#set -x

URL="https://cmstags.cern.ch/tc/ReleasesXML?anytype=1&architecture=slc5_amd64_gcc462"
wget_answer=$(wget --no-check-certificate -q "$URL")
if [ $? -ne 0 ]; then
  exit;
fi
vartest=""
path=""
res=""
saverel="1"

grep CMSSW /home/mpetek/ReleasesXML\?anytype\=1\&architecture\=slc5_amd64_gcc462 | grep Announced | cut -d\" -f2 > output.txt
while read rel;
do
	echo $rel;
#check if is a patch or a full version	
	if echo "$rel" | grep patch; then
		  path="cmssw-patch";
	else
		  path="cmssw";
	fi;
                        if [ -d /home/mpetek/slc5_amd64_gcc462/cms/$path/$rel ]; then
#				echo 'already installed';
			else
#				echo 'must be installed';
                                saverel=$rel;
				break;
			fi		
saverel=$rel;
done < output.txt 
rel=$saverel
if [ $saverel == "1" ]; then
	rm -f /home/mpetek/ReleasesXML\?anytype\=1\&architecture\=slc5_amd64_gcc462
	rm -f output.txt
	exit;
fi

allowedUpdate=1 ;

running=`ps ax | grep install | grep -v grep | grep -v vim | grep bash | wc -l`
runningBash=`ps ax | grep install | grep -v grep | grep -v vim | wc -l`
if [ $running -eq 0 ] ; then
  running=$(($runningBash-1)) ;
fi
if [ $running -gt 2 ] ; then
  allowedUpdate=0;
  reason="still running /" ;
fi

if [ $allowedUpdate -eq 1 ] ; then
    echo "`date`: Updating first, Installing ${rel} " | mail -s "CMSSW ${rel} installation started" markoptk@gmail.com ;

  fi
  source /home/mpetek/slc5_amd64_gcc462/external/apt/*/etc/profile.d/init.sh ;
  source /home/mpetek/cmsset_default.sh ;
  apt-get update ;
  apt-get -y install "cms+$path+$rel" ;
  done=$? ;

rsync -Cravzp /home/mpetek/slc5_amd64_gcc462/cms/ mpetek@cmscvmfs-ctl:/home/mpetek/slc5_amd64_gcc462/cms/

if [ "$res" -eq 1 ] ; then
    echo "`date`: install of ${rel} finished " | mail -s "CMSSW ${rel} installation finished" markoptk@gmail.com
    rm -f /home/mpetek/ReleasesXML\?anytype\=1\&architecture\=slc5_amd64_gcc462;
    rm -f output.txt;
    exit;
fi

reason="$reason condition failed" ;

echo "Release: $res || Time of Update: $itsTime     Running: $running   Allow: $allowedUpdate   Reason: $reason   Updated: $done  `echo ; ps ax | grep update-release | grep -v grep | grep -v vim`" | mail -s "CMSSW update ?" markoptk@gmail.com

rm -f /home/mpetek/ReleasesXML\?anytype\=1\&architecture\=slc5_amd64_gcc462
rm -f output.txt


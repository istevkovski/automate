#Automate your chia plotting

while getopts ":h" flag;
do
    case "${flag}" in
        h)
        	echo -e "\e[1mPositional Parameters:";
        	echo -e "\e[0m1) Current disk to plot";
        	echo "2) Final disk to finish and stop at";
        	echo "3) Increment number";
        	echo "4) Computer name ex. /media/\$computerName/disk/";
        	echo "5) Number of plots";
        	echo "6) Farmer public key";
        	echo "7) Pool public key";
        	exit 1;
        ;;
    esac
done

#Disk to start counting from
current=${1:-1}
#Disk to end counting at
endDisk=${2:-$current}
#Increment disk by number
increment=${3:-1}

#Computer Name
computerName=${4:-plotter2}
#Number Of Plots
numberOfPlots=${5:-36}
#Farmer Public Key
farmerPublicKey=${6:-ad909e7e86c7b35373105706c11644f7f29592bdfc971c22088e8f18bf8bfe436a3af935b1193b0d14076715cdfd635b}
#Pool Public Key
poolPublicKey=${7:-b5f67c61228b9308f73f15c380bb496a6f47cc9e6f0e16107689443d46e5b159737240c65eb905313ce31b72025db0d5}
#Singleton Address
singletonAddress=${8:-xch1ej3wjx6pwyh800rfev5sw8fgc2u8yvc8rrlye9cxr9ftxsj2fpsscd27v6}

echo -e "\033[0;31m           :::     :::    ::: ::::::::::: ::::::::    :::   :::       ::: ::::::::::: :::::::::: ";
echo -e "\033[0;33m        :+: :+:   :+:    :+:     :+:    :+:    :+:  :+:+: :+:+:    :+: :+:   :+:     :+:         ";
echo -e "\033[1;33m     + :+   +:+  +:+    +:+     +:+    +:+    +:+ +:+ +:+:+ +:+  +:+   +:+  +:+     +:+          ";
echo -e "\033[1;32m    +#++:++#++: +#+    +:+     +#+    +#+    +:+ +#+  +:+  +#+ +#++:++#++: +#+     +#++:++#      ";
echo -e "\033[0;36m   +#+     +#+ +#+    +#+     +#+    +#+    +#+ +#+       +#+ +#+     +#+ +#+     +#+            ";
echo -e "\033[0;34m  #+#     #+# #+#    #+#     #+#    #+#    #+# #+#       #+# #+#     #+# #+#     #+#             ";
echo -e "\033[0;35m ###     ###  ########      ###     ########  ###       ### ###     ### ###     ##########       ";
echo -e "\033[1;35m                                  Created by: natural_i                                          ";
echo -e "\e[97m";

while [ $current -le $endDisk ]
do	
	./chia_plot -f $farmerPublicKey -c $singletonAddress -n $numberOfPlots -r 16 -u 256 -t /mnt/tmp/ -2 /mnt/tmp/ -d /media/$computerName/d$current/
	current=$(( $current + $increment ))
done

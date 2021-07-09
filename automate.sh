#!/bin/bash
#Automate your chia plotting
# --------------------- Do Not Edit ---------------------
file="./.env"
[ -f $file ] && source .env # Source .env if it exists.

# --------------------- Variables ---------------------
# Disk to start plotting from
startDisk=${START_DISK:-1}
# Disk to end plotting at
endDisk=${END_DISK:-1}
# Increment disk by n
increment=${INCREMENT:-1}
# Computer Name
pcname=${PC_NAME:-"plotter2"}
# Number Of Plots
numberOfPlots=${NUMBER_OF_PLOTS:-36}
# Plots type
plotsType=${PLOTS_TYPE:-"pool"}
# Farmer Public Key
farmerPublicKey=${FARMER_PUBLIC_KEY:-"ad909e7e86c7b35373105706c11644f7f29592bdfc971c22088e8f18bf8bfe436a3af935b1193b0d14076715cdfd635b"}
# Pool Public Key
poolPublicKey=${POOL_PUBLIC_KEY:-"b5f67c61228b9308f73f15c380bb496a6f47cc9e6f0e16107689443d46e5b159737240c65eb905313ce31b72025db0d5"}
# Singleton Address
singletonAddress=${SINGLETON_ADDRESS:-"xch1ej3wjx6pwyh800rfev5sw8fgc2u8yvc8rrlye9cxr9ftxsj2fpsscd27v6"}


# --------------------- Functions ---------------------
# Print the help message
showHelp() {
cat << EOF
Please configure the script fully with all flags on the first run to set her defaults or edit the script
and change its default values.
Once the defaults are set, you can only modify the -sd -ed flags on her next run.

Usage: ${0##*/} [-h] [-rv] [-sd NUM] [-ed NUM] [-i NUM] [-pcn STRING]...

Available flags:
	-h | --help					display this help and exit
	-rv | --showvars			show and test all variables and exit

	-sd | --startdisk			set disk to start plotting from
	-ed | --enddisk				set disk to end plotting at
	-i	| --increment			set disk counting (jump n disks)
	-pcn | --pcname				set computer name (used for disks ex. /media/{pcname}/{diskname})
	-tp | --nplots				set number of total plots to make per disk
	-pt | --plottype			set the plot type "solo" || "pool"
	
	-fpk | --farmerkey			set farmer public key
	-ppk | --poolkey			set pool public key
	-sa | --singletonaddress	set singleton address

EOF
}

# Create and set a .env configuration
writeEnvDefaultConfiguration() {
	[ -f $file ] && rm $file # Remove .env if it exists
	# Write new env variables
	echo "START_DISK=$startDisk" >> "$file"
	echo "END_DISK=$endDisk" >> "$file"
	echo "INCREMENT=$increment" >> "$file"
	echo "PC_NAME=\"$pcname\"" >> "$file"
	echo "NUMBER_OF_PLOTS=$numberOfPlots" >> "$file"
	echo "PLOTS_TYPE=\"$plotsType\"" >> "$file"
	echo "FARMER_PUBLIC_KEY=\"$farmerPublicKey\"" >> "$file"
	echo "POOL_PUBLIC_KEY=\"$poolPublicKey\"" >> "$file"
	echo "SINGLETON_ADDRESS=\"$singletonAddress\"" >> "$file"
}

# Set print to the terminal default color
defaultPrintColor() {
	printf "\e[0m"
	printf "\e[39m"
	printf "\e[49m"
}

# Render the ASCII logo
renderLogo() {
	printf "\033[0;31m           :::     :::    ::: ::::::::::: ::::::::    :::   :::       ::: ::::::::::: :::::::::: \n"
	printf "\033[0;33m        :+: :+:   :+:    :+:     :+:    :+:    :+:  :+:+: :+:+:    :+: :+:   :+:     :+:         \n"
	printf "\033[1;33m     + :+   +:+  +:+    +:+     +:+    +:+    +:+ +:+ +:+:+ +:+  +:+   +:+  +:+     +:+          \n"
	printf "\033[1;32m    +#++:++#++: +#+    +:+     +#+    +#+    +:+ +#+  +:+  +#+ +#++:++#++: +#+     +#++:++#      \n"
	printf "\033[0;36m   +#+     +#+ +#+    +#+     +#+    +#+    +#+ +#+       +#+ +#+     +#+ +#+     +#+            \n"
	printf "\033[0;34m  #+#     #+# #+#    #+#     #+#    #+#    #+# #+#       #+# #+#     #+# #+#     #+#             \n"
	printf "\033[0;35m ###     ###  ########      ###     ########  ###       ### ###     ### ###     ##########       \n"
	printf "\033[1;35m                                  Created by: natural_i                                          \n"
	printf "\n"
	defaultPrintColor
}

# Start plotting disk for pool
plotdiskPool() {
	./chia_plot -f $farmerPublicKey -c $singletonAddress -n $numberOfPlots -r 16 -u 256 -t /mnt/tmp/ -2 /mnt/tmp/ -d /media/$pcname/d$current/
}

# Start plotting disk for solo
plotdiskSolo() {
	./chia_plot -f $farmerPublicKey -p $poolPublicKey -n $numberOfPlots -r 16 -u 256 -t /mnt/tmp/ -2 /mnt/tmp/ -d /media/$pcname/d$current/
}

# Render all variables (for testing)
renderVariables() {
	printf "\e[1mDisk to start from:\e[0m $startDisk\n"
	printf "\e[1mDisk to end at:\e[0m $endDisk\n"
	printf "\e[1mIncrement disk by:\e[0m $increment\n"
	printf "\e[1mComputer name:\e[0m $pcname\n"
	printf "\e[1mNumber of plots to create:\e[0m $numberOfPlots\n"
	printf "\e[1mType of plots to create:\e[0m $plotsType\n"
	printf "\e[1mFarmer Public Key:\e[0m $farmerPublicKey\n"
	printf "\e[1mPool Public Key:\e[0m $poolPublicKey\n"
	printf "\e[1mSingleton Address:\e[0m $singletonAddress\n"
}

# Initialize automate
init() {
	# Set current to the starting disk
	current=$startDisk
	# Render the logo
	renderLogo

	while [[ $current -le $endDisk ]]
	do
		if [[ $plotsType == "solo" ]]
		then
			echo "Plotting solo plots..."
			# plotdiskSolo
		elif [[ $plotsType == "pool" ]]
		then
			echo "Plotting pool plots..."
			# plotdiskPool
		else
			echo "Please set a valid plot type."
			break
		fi
		current=$(($current + $increment))
	done
}


# --------------------- Flags Handle ---------------------
while :; do
	case $1 in
		-h | --help)
			showHelp # Display a usage synopsis.
			exit
			;;
		-rv | --showvars) # Render all variables and exit (does not init)
			renderVariables
			exit
			;;
		-sd | --startdisk) # Set the disk to plot from
			startDisk=$2
			endDisk=$2 # Set end disk to the start disk by default
			shift
			;;
		-ed | --enddisk) # Set the disk to stop plotting at
			endDisk=$2 # Set end disk
			shift
			;;
		-i | --increment) # Increment disks by n
			increment=$2
			shift
			;;
		-pcn | --pcname) # Set computer name, used to run disks as: /media/{pcname}/{diskname}
			pcname=$2
			shift
			;;
		-tp | --nplots) # Set number of plots to plot in a single instance
			numberOfPlots=$2
			shift
			;;
		-pt | --plottype) # Set type of plots to plot (Pool | Solo)
			plotsType=$2
			shift
			;;
		-fpk | --farmerkey) # Set Farmer Public Key
			farmerPublicKey=$2
			shift
			;;
		-ppk | --poolkey) # Set Pool Public Key
			poolPublicKey=$2
			shift
			;;
		-sa | --singletonaddress) # Set Singleton Address
			singletonAddress=$2
			shift
			;;
		--) # End of all options.
			shift
			break ;;
		-?*)
			printf 'WARRNING: Unknown flag (ignored): %s\n' "$1" >&2
			;;
		*) # Default case: No more options, so break out of the loop.
			writeEnvDefaultConfiguration
			init
			break ;;
	esac

	shift
done

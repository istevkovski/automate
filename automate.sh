#!/bin/bash
# -------------------------- Automate --------------------------
# Automate your chia plotting with Automate!
# Version: 1.0.4
# Created by: @natural_i
# --------------------------------------------------------------


# --------------------- Do Not Edit ---------------------
file="./.env"
[ -f $file ] && source .env # Source .env if it exists.

# --------------------- Variables ---------------------
diskPrefix=${DISK_PREFIX:-"d"}
# Disk to start plotting from
startDisk=1
# Disk to end plotting at
endDisk=startDisk
# Increment disk by n
increment=${INCREMENT:-1}
# Computer Name
pcname=${PC_NAME:-"plotter2"}
# Mounting point
mountingPoint=${MOUNTING_POINT:-"media"}
# Number Of Plots
numberOfPlots=false
# Type of plots
isOGPlot=false
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
Please configure the script fully with all flags on the first run to set her defaults
or edit the .env file and change its default values.
Once the defaults are set, you can only modify the -sd -ed flags on her next run.

Usage: ${0##*/} [-h] [-rv] [-sd NUM] [-ed NUM] [-i NUM] [-pcn STRING]...

Available flags:
	-h   |  --help            display this help and exit
	-rv  |  --showvars        show and test all variables and exit

	-dp  |  --diskprefix      set the disk prefix
	-sd  |  --startdisk       set disk to start plotting from
	-ed  |  --enddisk         set disk to end plotting at (including it)
	-i   |  --increment       set disk counting (jump n disks)
	-pcn |  --pcname          set computer name (used for disks ex. /media/{pcname}/{diskname})
	-mp  |  --mntpnt          set the disk mounting point (/media or /mnt etc...)
	-tp  |  --nplots          set number of total plots to make per disk
	-og  |  --ogplot          create og plots (-p mode)
	
	-fpk |  --farmerkey       set farmer public key
	-ppk |  --poolkey         set pool public key
	-sa  |  --singleton       set singleton address

EOF
}

# Create and set a .env configuration
writeEnvDefaultConfiguration() {
	[ -f $file ] && rm $file # Remove .env if it exists
	# Write new env variables
	echo "DISK_PREFIX=\"$diskPrefix\"" >> "$file"
	echo "INCREMENT=$increment" >> "$file"
	echo "PC_NAME=\"$pcname\"" >> "$file"
	echo "MOUNTING_POINT=\"$mountingPoint\"" >> "$file"
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

# Calculate plots based on disk free space if no custom value is provided
handleNumberOfPlots() {
	# If no number of plots is provided, calculate by disk free space
	if [[ $numberOfPlots -eq false ]]
	then
		numberOfPlots=$(( $1 / 109 ))
	fi
}

# Start plotting disk for pool
plotdiskPool() {
	./chia_plot -f $farmerPublicKey -c $singletonAddress -n $numberOfPlots -r 16 -u 256 -t /mnt/tmp/ -2 /mnt/tmp/ -d /$mountingPoint/$pcname/$diskPrefix$current/
}

# Start plotting disk for solo
plotdiskOG() {
	./chia_plot -f $farmerPublicKey -p $poolPublicKey -n $numberOfPlots -r 16 -u 256 -t /mnt/tmp/ -2 /mnt/tmp/ -d /$mountingPoint/$pcname/$diskPrefix$current/
}

# Render all variables (for testing)
renderVariables() {
	printf "\e[1mDisk Prefix:\e[0m $diskPrefix\n"
	printf "\e[1mDisk to start from:\e[0m $startDisk\n"
	printf "\e[1mDisk to end at:\e[0m $endDisk\n"
	printf "\e[1mIncrement disk by:\e[0m $increment\n"
	printf "\e[1mComputer name:\e[0m $pcname\n"
	printf "\e[1mDisk mounting point:\e[0m $mountingPoint\n"
	printf "\e[1mPlotting OG plots:\e[0m $isOGPlot\n"
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
		# Get current disk free space
		diskFreeSpace=`df --block-size=GB --output=avail /$mountingPoint/$pcname/$diskPrefix$current/ | tail -1 | tr -dc '0-9'`
		
		# Calculate number of plots if no user value is present
		handleNumberOfPlots $diskFreeSpace

		# Handle type of plots to create
		if [[ $isOGPlot = true ]]
		then
			plotdiskOG
		else
			plotdiskPool
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
		-dp | --diskprefix) # Set the disk prefix
			diskPrefix=$2
			shift
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
		-mp | --mntpnt) # Set the disk mounting point (/media or /mnt etc...)
			mountingPoint=$2
			shift
			;;
		-tp | --nplots) # Set number of plots to plot in a single instance
			numberOfPlots=$2
			shift
			;;
		-og | --ogplot) # Turn on plotting og plots (-p mode)
			isOGPlot=true
			;;
		-fpk | --farmerkey) # Set Farmer Public Key
			farmerPublicKey=$2
			shift
			;;
		-ppk | --poolkey) # Set Pool Public Key
			poolPublicKey=$2
			shift
			;;
		-sa | --singleton) # Set Singleton Address
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

#!/bin/bash

######################################################################################################
# download_viirs.sh 
# Written by Juan Sebastian Lozano
# Dresciption: 
#   This bash script downloads and unzips the VIIRS composites and then cleans up the directoru
# INPUT: ./links.csv (produced by EOG_scrape.py), ./oeg_token.txt (produced by get_token.sh) and STDIN
# OUTPUT: ./*.TIF (VIIRS composies)
######################################################################################################

# Get user preferences 

## Get Year 
read -p "Download all years? [y/n]" all_years </dev/tty
if [[ "${all_years}" != "y" ]]
	then 
	read -p "Which year would you like to download? [2012-2021]" year </dev/tty
		if (( ${year} > 2021 || ${year} < 2012 )) 
		then 
			echo "Incorrect input, terminating script"
			exit 1
		fi
fi

## Get Month
read -p "Download all months? [y/n]" all_months </dev/tty
if [[ "${all_months}" != "y" ]]
	then 
	read -p "Which month would you like to download? [01-12]" month </dev/tty
	if (( ${#month} != 2 )) 
		then 
			echo "Incorrect input, terminating script"
			exit 1
	fi 
fi

token=$(cat ./eog_token.txt)
echo "${token}"
# Download images
file=./links.csv
IFS="," 
cat ${file} | while read -ra row; 
do  
	url="${row[4]}"
	# First only download vcmcfg  
	if [[ ( "${row[2]}" == "vcmcfg" ) ]]
	then
		if [[ "${all_years}" == "y" ]]
		then 
			if [[ "${all_months}" == "y" ]]
			#all years + all months
            echo "${url}"
			then wget --header="Authorization: Bearer $token" -O "./${row[0]}_${row[1]}_${row[3]}.tgz" ${url}
			else 
			#all years + specific month
				if [[ ( "${row[1]}" == "${month}" ) ]]
				then wget --header="Authorization: Bearer $token" -O "./${row[0]}_${row[1]}_${row[3]}.tgz" ${url}
				fi
			fi
		elif [[ "${all_months}" == "y" ]]
		then
			#specific year + all months
			if [[ "${row[0]}" == "${year}" ]]
			then wget --header="Authorization: Bearer $token" -O "./${row[0]}_${row[1]}_${row[3]}.tgz" ${url}
			fi
		else 
			#specific year + specific month 
			if [[ ( "${row[1]}" == "${month}" ) && ( "${row[0]}" == "${year}" ) ]]
			then wget --header="Authorization: Bearer $token" -O "./${row[0]}_${row[1]}_${row[3]}.tgz" ${url}
			fi
		fi
	fi 
done  

# Unzip files 

ls *.tgz | parallel gzip -d

for file in *.tar 
do
  mv "$file" "${file%.tar}.TIF"    
done

#!/bin/bash

######################################################################################################
# get_token.sh 
# Written by Juan Sebastian Lozano
# Dresciption: 
#   This bash script gets the OAuth Token needed to download the VIIRs Rasters
# INPUT: two positional arguments USERNAME and PASSWORD
# OUTPUT: ./eog_token.txt
######################################################################################################
response=`curl -L -d 'client_id=eogdata_oidc'\
 -d 'client_secret=2677ad81-521b-4869-8480-6d05b9e57d48'\
 -d 'username=$1' \
 -d 'password=$2' \
 -d 'grant_type=password' 'https://eogauth.mines.edu/auth/realms/master/protocol/openid-connect/token' | python -m json.tool` 

access_token=`echo $response|jq '.access_token'|sed 's/^.//;s/.$//'`

echo "${access_token}" >| eog_token.txt
#!/bin/bash

##################################################
#   Ensure the environment matches what is needed
##################################################

# We do NOT want two backends running at one time so verify we dont have anything already running
# docker ps             list all dockers
# grep api-sonarqube-1  filter down to one instance
# wc -l                 Count the line breaks
# xargs                 Trims the whitespace around it
# @return               the number of instances of "api-sonarqube-1" (0, 1)
printf "\nChecking whether we should start a new sonarqube backend\n"
RUNNING=$(docker ps | grep api-sonarqube-1 | wc -l | xargs);
if [ "${RUNNING}" -eq "1" ];then
    printf "\033[0;31mAppears to already have a healthy sonarqube backend\033[0m\n\n"
    exit 1
fi

##################################################
#   Setup the private docker network (if needed)
##################################################

# Ensure we have the network we want
printf '\nEnsure we have a dedicated network...'
( docker network ls | grep sftpgo-sq || docker network create sftpgo-sq ) > /dev/null 2>&1
printf "Done!\n"

##################################################
#   Start the environment and check its health
##################################################

# Start the sonarcloud services in the background
docker-compose -f docker/compose.sonarqube.yml up -d > /dev/null 2>&1

# Wait for the environment to be operational and healthy
attempt_counter=0
printf '\nWaiting for a healthy sonarcloud instance'
until $(curl --output /dev/null --silent --fail -u admin:admin http://localhost:9000/api/system/health); do
    if [ ${attempt_counter} -eq 30 ];then
      echo "\nMax attempts reached: Failed to detect a healthy sonarcloud instance after 60 seconds"
      exit 1
    fi

    printf '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 2
done

##################################################
#   Configure the environment below here
##################################################

printf "healthy!\nSleeping 5 extra seconds...\n"
sleep 5

# Ensure the username is updated (fails silently)
# On first run, this changes it from admin to sonar123
# On subsequent runs, it fails without making any modifications
printf '\nConfiguring username and password on first run...'
curl -u admin:admin -X POST "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=sonar123"
printf "done\n"

##################################################
#   How do we want to close?
##################################################

# Offer to show logs if 'y' but otherwise show the login
printf "\n\n########################################
# 
# \tAddress: localhost:9000
# \tUsername: admin
# \tPassword: sonar123
#
# \tHappy analyzing!
# 
########################################\n"

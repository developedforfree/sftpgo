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
RUNNING=$(docker ps | grep docker-sonarqube-1 | wc -l | xargs);
if [ "${RUNNING}" -eq "0" ];then
    printf "\033[0;31mError: No sonarqube backend can be found\033[0m\n\n"
    exit 1
fi

printf "\nChecking whether we are already analyzing the given folder\n"
RUNNING=$(docker ps | grep sonarqube_analyze_sftpgo | wc -l | xargs);
if [ "${RUNNING}" -eq "1" ];then
    printf "\033[0;31mError: Already has an analyze process executing\033[0m\n\n"
    exit 1
fi

##################################################
#   Run the analysis
##################################################

# Run the code analysis
docker run \
    --rm \
    --name sonarqube_analyze_sftpgo \
    -e SONAR_LOGIN="admin" \
    -e SONAR_PASSWORD="sonar123" \
    -v "./:/usr/src" \
    -v "./docker/sonar-project.properties:/usr/src/sonar-project.properties" \
    --network="container:docker-sonarqube-1" \
    sonarsource/sonar-scanner-cli

##################################################
#   View the results
##################################################

# Open the report dashbord
open "http://localhost:9000/dashboard?id=SFTPGo"
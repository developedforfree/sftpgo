# Get the results from the last SonarQube scan
RESULT=$(curl -s -u "admin:sonar123" http://localhost:9000/api/qualitygates/project_status?projectKey=SFTPGo)

# Use the results and check if we have both "OK" and "compliant"
# We do this in a seperate step incase we want to send the RESULT value to a PR comment
OK=$(echo "$RESULT" | grep "OK" | grep "compliant" | wc -l | xargs)

# Exit with a failure if we dont meet compliance requirements
if [ $OK -lt 1 ]
then
    echo $RESULT
    exit 1
fi
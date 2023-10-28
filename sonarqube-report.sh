# Install the appropriate NPM package
npm install -g sonar-report

# Generate the HTML-based report to attach as an artifact to the PR
sonar-report \
  --sonarurl="http://localhost:9000" \
  --sonarcomponent="SFTPGo" \
  --project="SFTPGo" \
  --sonarusername="admin" \
  --sonarpassword="sonar123" \
  --output="sonarqube-report.html"
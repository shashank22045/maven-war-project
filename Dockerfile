FROM tomcat:9.0.119-jdk8

# Remove the default Tomcat welcome page to avoid conflicts
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy your war file and rename it to ROOT.war
COPY target/devnew.war /usr/local/tomcat/webapps/ROOT.war


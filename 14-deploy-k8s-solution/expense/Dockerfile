# Use the official Quarkus JVM base image
FROM registry.access.redhat.com/ubi8/openjdk-17:1.18

# Set the working directory
WORKDIR /work/

# Copy the jar file
COPY target/quarkus-app/lib/ /work/lib/
COPY target/quarkus-app/*.jar /work/
COPY target/quarkus-app/app/ /work/app/
COPY target/quarkus-app/quarkus/ /work/quarkus/

# Make port 8080 available
EXPOSE 8080

# Set the user to non-root
USER 185

# Configure the JAVA_OPTIONS, you can adjust this as necessary
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"

# Run the application
ENTRYPOINT [ "/opt/jboss/container/java/run/run-java.sh" ]

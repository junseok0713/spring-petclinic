FROM openjdk:17-oracle
CMD ["./mvnw","clean","package"]
ARG JAR_FILE_PATH=targer/*.jar
COPY ${JAR_FILE_PATH} spring-petclinic.jar
ENTRYPOINT ["java","-jar","spring-petclinic.jar"]

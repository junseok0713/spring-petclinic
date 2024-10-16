FROM openjdk:17-oracle
CMD ["./mvnw","clean","package"]
ARG JAR_FILE_PATH=tager/*.jar
COPY ${JAR_FILE_PATH} spring-petclinic.jar
ENTRYPOINT ["java","-jar","spring-petclinic.jar"]
// 도커 허브적용시키려는 문구

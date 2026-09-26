pipeline {
    agent any  // Use any available agent
    environment {
        PATH ="/opt/apache-tomcat-9.0.119/bin:$PATH"  
        DOCKER_HOST_USER = 'docker' // e.g., 'ubuntu' or 'ec2-user'
        DOCKER_HOST_IP = 'ec2-54-81-124-179.compute-1.amazonaws.com'
        DOCKER_APP_DIR = '/opt/' // Remote directory for your app files
        WAR_FILE_NAME = 'devnew.war'
    }

    tools {
        maven 'maven'  // Ensure this matches the name configured in Jenkins
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/s43861999/maven-war-project.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'  // Run Maven build
            }
        }
        stage('connect to server') {
            steps {
              sshagent(['tomcat']) {

                 sh "ls -l $WORKSPACE/target/"
                 sh "pwd"
                 sh "scp -o StrictHostKeyChecking=no $WORKSPACE/target/devnew.war tomcat@ec2-54-81-124-179.compute-1.amazonaws.com:/opt/apache-tomcat-9.0.119/webapps"


                }
       
               }
         }    
        stage('Deploy to Docker Host') {
            steps {
                script {
                    // Connect to the remote Docker host using the stored SSH credentials
                    sshagent(['docker']) {

                        // --- 1. Copy necessary files to the remote machine
                        // The `scp` command copies the WAR file and Dockerfile
                        sh "scp target/*.war ${DOCKER_HOST_USER}@${DOCKER_HOST_IP}:${DOCKER_APP_DIR}"
                        sh "scp Dockerfile ${DOCKER_HOST_USER}@${DOCKER_HOST_IP}:${DOCKER_APP_DIR}"

                        // --- 2. Execute Docker commands on the remote machine
                        // The `ssh` command runs commands on the remote machine
                        sh "ssh -tt ${DOCKER_HOST_USER}@${DOCKER_HOST_IP} 'cd ${DOCKER_APP_DIR} && docker stop tomcat_container || true && docker rm tomcat_container || true && docker rmi tomcat_app_image || true'"

                        echo 'Building new Docker image...'
                        sh "ssh -tt ${DOCKER_HOST_USER}@${DOCKER_HOST_IP} 'cd ${DOCKER_APP_DIR} && docker build -t tomcat_app_image .'"

                        echo 'Running new container...'
                        sh "ssh -tt ${DOCKER_HOST_USER}@${DOCKER_HOST_IP} 'docker run -d --name tomcat_container -p 8090:8080 tomcat_app_image'"
                    }
                }
            }
        }
         
    }
}

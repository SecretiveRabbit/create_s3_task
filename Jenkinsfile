pipeline {
    agent any
    
    stages {
        
        stage('Pull') {
            steps {
                sh 'git clone https://github.com/SecretiveRabbit/create_s3_task.git'
            }
        }
        
        
        stage('Build') {
            steps {
                sh 'chmod +x create_s3_task/create_s3.sh'
            }
        }
        
        stage('Run script') {
            steps {
                sh 'create_s3_task/create_s3.sh'
            }
        }
    }
}

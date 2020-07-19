pipeline {
    agent any
    options {
        ansiColor('xterm')
    }
    parameters {
        string(name: 'DEST_REGION', defaultValue: 'ap-southeast-2', description: 'Destination Region')
    }
    stages {
        stage('Build') {
            steps {
                sh 'terraform init'
                sh 'terraform plan -var "region=${DEST_REGION}"'
                sh 'terraform apply -var "region=${DEST_REGION}" --auto-approve'
            }
        }
    }
}
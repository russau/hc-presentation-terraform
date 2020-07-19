pipeline {
    agent any
    options {
        ansiColor('xterm')
        copyArtifactPermission('hc-presentation-packer');
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
                sh 'mkdir certs || true'
                sh 'terraform output web_cert_private_key_ciphertext | base64 --decode > certs/web_cert_private_key_ciphertext.bin'
                sh 'terraform output web_issuer_pem > certs/web_issuer.pem'
                sh 'terraform output web_certificate_pem > certs/web_certificate.pem'
                archiveArtifacts artifacts: 'certs/**'
            }
        }
    }
}

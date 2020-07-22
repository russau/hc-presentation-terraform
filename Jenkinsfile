pipeline {
    agent any
    options {
        ansiColor('xterm')
        copyArtifactPermission('hc-presentation-packer');
    }
    parameters {
        string(name: 'DEST_REGION', defaultValue: 'ap-southeast-2', description: 'Destination Region')
        string(name: 'CREATE_INSTANCE', defaultValue: 'true', description: 'Create the instance')
    }
    stages {
        stage('Build') {
            steps {
                // we want a workspace per region, create one if we don't already have one
                sh 'terraform workspace list | grep -q ${DEST_REGION} || terraform workspace new ${DEST_REGION}'
                sh 'terraform workspace select ${DEST_REGION}'
                sh 'terraform init'
                sh 'terraform plan -var "region=${DEST_REGION}" -var "create_instance=${CREATE_INSTANCE}"'
                sh 'terraform apply -var "region=${DEST_REGION}" -var "create_instance=${CREATE_INSTANCE}" --auto-approve'
                sh 'mkdir -p certs/${DEST_REGION} || true'
                sh 'terraform output web_cert_private_key_ciphertext | base64 --decode > certs/${DEST_REGION}/web_cert_private_key_ciphertext.bin'
                sh 'terraform output web_issuer_pem > certs/${DEST_REGION}/web_issuer.pem'
                sh 'terraform output web_certificate_pem > certs/${DEST_REGION}/web_certificate.pem'
                archiveArtifacts artifacts: 'certs/*/*'
            }
        }
    }
}

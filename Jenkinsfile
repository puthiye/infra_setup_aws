#!/usr/bin/env groovy

pipeline { 
agent any

        stages {

         stage("install docker/git - rhel") {

            steps{

                script{
                          
                          //credentials -> secret file 
                          withCredentials([file(credentialsId: 'SSH-PRIVATE-KEY', variable: 'mySecretFile')]) {
    
                                           sh '''
                                              echo "Copy the content to /tmp location `cat $mySecretFile > /tmp/key.file`"
                                              chmod 700 /tmp/key.file
                                              '''
                          }
                    
                         sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${DEPLOY_ENDPOINT}, ./ansible/setup.yml --extra-vars="ansible_ssh_private_key_file=/tmp/key.file ansible_user=ec2-user" '
                          
                         //delete the ssh key after use
                         dir("/tmp/key.file") {
                              deleteDir()
                         }      

                      }                   

                }
      }
 

  } //end of stages
} //end of pipeline

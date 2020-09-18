#!/usr/bin/env groovy

def DEPLOY_ENDPOINT 

pipeline { 
agent any

        stages {

                 stage("infra setup") {

                  steps{

                           script{
  
                                    //credentials -> aws credentials
                                    withCredentials(
                                    [[
                                         $class: 'AmazonWebServicesCredentialsBinding',
                                         accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                         credentialsId: 'AWS_CLI',  
                                         secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                                   ]]) {
                                            
                                            
                                           dir('terraform')
                                           {
                                               sh "terraform init" 
                                               sh "terraform apply -auto-approve=true"      
                                           }  
                                                       
                                           result = sh(returnStdout: true, script: "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                                                           AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                                                           AWS_REGION=ap-southeast-2 \
                                                           /usr/local/bin/aws ec2 describe-instances --filters \"Name=tag:Name,Values=demo-asg\" | grep PublicIpAddress") 
                        
                                           DEPLOY_ENDPOINT = "${result}".tokenize(':')[1].minus(",")
                                           println("ip=${DEPLOY_ENDPOINT}")  
                                    
                                    }
      
      
                                    

                           }
                  }
               }


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
                    
                    
                    
                        println("ip here =${DEPLOY_ENDPOINT}")  
                           
                                  sh """ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i \"${DEPLOY_ENDPOINT}\", ./ansible/setup.yml --extra-vars="ansible_ssh_private_key_file=/tmp/key.file ansible_user=ec2-user" """
                       
                       
                       
                         //delete the ssh key after use
                         dir("/tmp/key.file") {
                              deleteDir()
                         }      

                      }                   

                }
      }
     

  } //end of stages
} //end of pipeline

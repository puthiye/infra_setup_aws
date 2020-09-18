#!/usr/bin/env groovy

def DEPLOY_ENDPOINT 
def skipBuild = 'false'

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
                                          //     sh "terraform init" 
                                           //    sh "terraform ${ACTION} -auto-approve=true"      
                                           }  
                                            
                                           if ("${ACTION}".equals('destroy'))
                                              skipBuild = 'true'
                                            
                                           result = sh(returnStdout: true, script: "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                                                           AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                                                           AWS_REGION=ap-southeast-2 \
                                                           /usr/local/bin/aws ec2 describe-instances --filters \"Name=tag:Name,Values=demo-asg\" | grep PublicIpAddress") 
                        
                                           DEPLOY_ENDPOINT = "${result}".tokenize(':')[1].minus(",")
                                           println("EC2 public ip=${DEPLOY_ENDPOINT}")  
                                                                               
                                    }
       

                           }
                  }
          }


         stage("install docker/git - rhel") {
                 
            when {
                    expression { return skipBuild == true ;}
             }    
               
            steps{

                script{
                          
                          //credentials -> secret file 
                          withCredentials([file(credentialsId: 'SSH-PRIVATE-KEY', variable: 'mySecret')]) {
    
                                     //wait for ssh to come up
                                     sleep(60)
                                     sh """ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i \"${DEPLOY_ENDPOINT}\", ./ansible/setup.yml --private-key \"${mySecret}\" --extra-vars="ansible_user=ec2-user" """  
                          }
                              

                      }                   

                }
      }
     

  } //end of stages
} //end of pipeline

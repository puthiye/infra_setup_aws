Prereqs:
   1) Create key pair in AWS with name as "key0"
   
   2) Jenkins with below Credentials
       a) SSH Username/Key (ID=dev-ssh)  - private key of compute instance
       b) Username with password  (ID=GIT_CREDS)  - github user credentials
       c) Secret file (ID=SSH-PRIVATE-KEY) - private key of compute instance
       d) AWS Credentials (ID=AWS_CLI) - aws access keys (requires CloudBees AWS Credentials plugin)

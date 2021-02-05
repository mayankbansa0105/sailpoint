pipeline {
    agent any

    stages {
        stage('Git clone') {
            steps {
                cleanWs()
               sh ' git clone https://github.com/mayankbansa0105/sailpoint.git '
            }
        }
        stage('Terraform plan') {
            
            steps {
/*                sh '''cd $WORKSPACE/sailpoint/Terraform_mssql
 ls -ltrh
  terraform init && terraform plan -out=tf.plan
  terraform show -json tf.plan | jq '.' > tf.json'''
             archiveArtifacts 'sailpoint/Terraform_mssql/*.json' */
      sh 'checkov --directory $WORKSPACE/sailpoint/Terraform_mssql/ -o junitxml > result.xml || true'
                    junit "result.xml"
             
  }
       
            }
    
              
      stage('Approval') {
          steps {
              script {
                  def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
              }
          }
      }
      stage ('Terraform Apply') {
          
          steps {
             sh ''' cd $WORKSPACE/sailpoint/Terraform_mssql
  terraform apply -auto-approve'''
              
          }
      }
        }
		}
		

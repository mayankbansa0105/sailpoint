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
             terraform init
  terraform apply -auto-approve'''
              
          }
      }
      
      stage ('DB schema creation') {
      steps {
         sh '''cd $WORKSPACE/sailpoint/Terraform_mssql
ip=`terraform output public_ip`
temp="${ip%\\"}"
publicip="${temp#\\"}"
echo $publicip 
sqlcmd -S $publicip -U SA -P 5Vnzur276332 -i $WORKSPACE/sailpoint/sql.sql -o output.txt
'''
      }
        }
		}
}

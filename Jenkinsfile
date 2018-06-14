def buildDesc = env.ghprbPullTitle

pipeline {
	agent any
    environment {
        cred_vcenter_adpiccolaus = credentials('02ce81e7-6ab7-4c43-bc82-6104fe08b769')
    }
    options {
        timeout(time: 1, unit: 'HOURS')
    }
	stages {
        stage('build-inventory') {
            steps {
                powershell '''
                    .\\Get-Inventory.ps1
                '''
            }
        }
        stage('push-inventory') {
            steps {
                powershell '''
                    .\\Push-Inventory.ps1
                '''
            }
        }
        stage('roll-inventory') {
            steps {
                powershell '''
                    .\\Set-Inventory.ps1
                '''
            }
        }
    }
}

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
        stage('set-job-info') {
            steps {
                script {
                    GIT_BRANCH_testing = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    currentBuild.description = env.ghprbPullTitle
                    echo env.GIT_BRANCH
                    echo env.GIT_LOCAL_BRANCH
                    echo GIT_BRANCH_testing
                }
            }
        }
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

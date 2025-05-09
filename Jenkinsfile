pipeline {
    agent any
    
    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_USER = "${DOCKER_CREDENTIALS_USR}"
        DOCKER_PASS = "${DOCKER_CREDENTIALS_PSW}"
        GIT_CREDENTIALS = credentials('github-credentials')
        GIT_USER = "${GIT_CREDENTIALS_USR}"
        GIT_PASS = "${GIT_CREDENTIALS_PSW}"
    }
    
    stages {
        stage('Prepare Environment') {
            steps {
                sh 'chmod +x setup.sh'
                sh './setup.sh'
            }
        }
        
        stage('Detect Changes') {
            steps {
                script {
                    // 변경된 파일 감지 (이전 커밋과 현재 커밋 비교)
                    def changedFiles = sh(script: "git diff --name-only HEAD~1 HEAD || git diff --name-only", returnStdout: true).trim()
                    
                    echo "Changed files: ${changedFiles}"
                    
                    // 각 서비스별 변경 여부 확인
                    env.CHANGED_ACCOUNT_SERVICE = changedFiles.contains('ssok-account-service/') ? 'true' : 'false'
                    env.CHANGED_USER_SERVICE = changedFiles.contains('ssok-user-service/') ? 'true' : 'false'
                    env.CHANGED_TRANSFER_SERVICE = changedFiles.contains('ssok-transfer-service/') ? 'true' : 'false'
                    env.CHANGED_NOTIFICATION_SERVICE = changedFiles.contains('ssok-notification-service/') ? 'true' : 'false'
                    env.CHANGED_GATEWAY = changedFiles.contains('ssok-gateway/') ? 'true' : 'false'
                    env.CHANGED_BLUETOOTH_SERVICE = changedFiles.contains('ssok-bluetooth-service/') ? 'true' : 'false'
                    
                    // common 모듈이 변경되면 모든 서비스 재빌드
                    if (changedFiles.contains('ssok-common/') || changedFiles.contains('build.gradle') || changedFiles.contains('settings.gradle')) {
                        echo "Common module or build configuration changed. Rebuilding all services."
                        env.CHANGED_ACCOUNT_SERVICE = 'true'
                        env.CHANGED_USER_SERVICE = 'true'
                        env.CHANGED_TRANSFER_SERVICE = 'true'
                        env.CHANGED_NOTIFICATION_SERVICE = 'true'
                        env.CHANGED_GATEWAY = 'true'
                        env.CHANGED_BLUETOOTH_SERVICE = 'true'
                    }
                    
                    echo "Account Service changed: ${env.CHANGED_ACCOUNT_SERVICE}"
                    echo "User Service changed: ${env.CHANGED_USER_SERVICE}"
                    echo "Transfer Service changed: ${env.CHANGED_TRANSFER_SERVICE}"
                    echo "Notification Service changed: ${env.CHANGED_NOTIFICATION_SERVICE}"
                    echo "Gateway changed: ${env.CHANGED_GATEWAY}"
                    echo "Bluetooth Service changed: ${env.CHANGED_BLUETOOTH_SERVICE}"
                }
            }
        }
        
        stage('Docker Login') {
            steps {
                sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
            }
        }
        
        // 계정 서비스 빌드 및 배포
        stage('Build & Deploy Account Service') {
            when { expression { return env.CHANGED_ACCOUNT_SERVICE == 'true' } }
            steps {
                withEnv(["DOCKER_USER=${DOCKER_USER}", "GIT_PASS=${GIT_PASS}"]) {
                    sh 'chmod +x jenkins/ssok-app/ssok-account-service/deploy.sh'
                    sh './jenkins/ssok-app/ssok-account-service/deploy.sh'
                    sh 'chmod +x jenkins/ssok-app/ssok-account-service/pipeline.sh'
                    sh './jenkins/ssok-app/ssok-account-service/pipeline.sh'
                }
                echo "Account Service build & deploy completed"
            }
        }
        
        // 사용자 서비스 빌드 및 배포
        stage('Build & Deploy User Service') {
            when { expression { return env.CHANGED_USER_SERVICE == 'true' } }
            steps {
                withEnv(["DOCKER_USER=${DOCKER_USER}", "GIT_PASS=${GIT_PASS}"]) {
                    sh 'chmod +x jenkins/ssok-app/ssok-user-service/deploy.sh'
                    sh './jenkins/ssok-app/ssok-user-service/deploy.sh'
                    sh 'chmod +x jenkins/ssok-app/ssok-user-service/pipeline.sh'
                    sh './jenkins/ssok-app/ssok-user-service/pipeline.sh'
                }
                echo "User Service build & deploy completed"
            }
        }
        
        // 송금 서비스 빌드 및 배포
        stage('Build & Deploy Transfer Service') {
            when { expression { return env.CHANGED_TRANSFER_SERVICE == 'true' } }
            steps {
                withEnv(["DOCKER_USER=${DOCKER_USER}", "GIT_PASS=${GIT_PASS}"]) {
                    sh 'chmod +x jenkins/ssok-app/ssok-transfer-service/deploy.sh'
                    sh './jenkins/ssok-app/ssok-transfer-service/deploy.sh'
                    sh 'chmod +x jenkins/ssok-app/ssok-transfer-service/pipeline.sh'
                    sh './jenkins/ssok-app/ssok-transfer-service/pipeline.sh'
                }
                echo "Transfer Service build & deploy completed"
            }
        }
        
        // 알림 서비스 빌드 및 배포
        stage('Build & Deploy Notification Service') {
            when { expression { return env.CHANGED_NOTIFICATION_SERVICE == 'true' } }
            steps {
                withEnv(["DOCKER_USER=${DOCKER_USER}", "GIT_PASS=${GIT_PASS}"]) {
                    sh 'chmod +x jenkins/ssok-app/ssok-notification-service/deploy.sh'
                    sh './jenkins/ssok-app/ssok-notification-service/deploy.sh'
                    sh 'chmod +x jenkins/ssok-app/ssok-notification-service/pipeline.sh'
                    sh './jenkins/ssok-app/ssok-notification-service/pipeline.sh'
                }
                echo "Notification Service build & deploy completed"
            }
        }
        
        // 게이트웨이 빌드 및 배포
        stage('Build & Deploy Gateway') {
            when { expression { return env.CHANGED_GATEWAY == 'true' } }
            steps {
                withEnv(["DOCKER_USER=${DOCKER_USER}", "GIT_PASS=${GIT_PASS}"]) {
                    sh 'chmod +x jenkins/ssok-app/ssok-gateway-service/deploy.sh'
                    sh './jenkins/ssok-app/ssok-gateway-service/deploy.sh'
                    sh 'chmod +x jenkins/ssok-app/ssok-gateway-service/pipeline.sh'
                    sh './jenkins/ssok-app/ssok-gateway-service/pipeline.sh'
                }
                echo "Gateway build & deploy completed"
            }
        }
        
        // 블루투스 서비스 빌드 및 배포
        stage('Build & Deploy Bluetooth Service') {
            when { expression { return env.CHANGED_BLUETOOTH_SERVICE == 'true' } }
            steps {
                withEnv(["DOCKER_USER=${DOCKER_USER}", "GIT_PASS=${GIT_PASS}"]) {
                    sh 'chmod +x jenkins/ssok-app/ssok-bluetooth-service/deploy.sh'
                    sh './jenkins/ssok-app/ssok-bluetooth-service/deploy.sh'
                    sh 'chmod +x jenkins/ssok-app/ssok-bluetooth-service/pipeline.sh'
                    sh './jenkins/ssok-app/ssok-bluetooth-service/pipeline.sh'
                }
                echo "Bluetooth Service build & deploy completed"
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir()
            sh 'docker logout'
        }
        success {
            echo 'CI/CD Pipeline completed successfully!'
        }
        failure {
            echo 'CI/CD Pipeline failed!'
        }
    }
}
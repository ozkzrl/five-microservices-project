pipeline {
    agent any

    environment {
        PROJECT_NAME = "five-microservices"
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Repository çekiliyor..."
                checkout scm
            }
        }

        stage('Stop Containers') {
            steps {
                echo "🛑 Containers durduruluyor..."
                sh 'chmod +x 01-stop-containers.sh'
                sh './01-stop-containers.sh'
            }
        }

        stage('Cleanup Images') {
            steps {
                echo "🧹 Eski image’lar siliniyor..."
                sh 'chmod +x 02-cleanup-images.sh'
                sh './02-cleanup-images.sh'
            }
        }

        stage('Build Images') {
            steps {
                echo "🏗️ Yeni image’lar build ediliyor..."
                sh 'chmod +x 03-build-images.sh'
                sh './03-build-images.sh'
            }
        }

        stage('Run Containers') {
            steps {
                echo "🚀 Yeni container’lar ayağa kaldırılıyor..."
                sh 'chmod +x 04-run-containers.sh'
                sh './04-run-containers.sh'
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment başarıyla tamamlandı!"
        }
        failure {
            echo "❌ Deployment başarısız! Logları kontrol et."
        }
    }
}

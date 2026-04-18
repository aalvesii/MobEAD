pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'SonarQubeScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Baixando o código do GitHub...'
                checkout scm
            }
        }

        stage('Build da Imagem Docker') {
            steps {
                echo 'Construindo a aplicação baseada no Dockerfile...'
                script {
                    dockerImage = docker.build("mobead-app:${env.BUILD_ID}")
                }
            }
        }

        stage('Testes Automatizados & SonarQube') {
            steps {
                echo 'Rodando análise de qualidade com SonarQube...'
                withSonarQubeEnv('Meu-SonarQube-Server') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=mobead -Dsonar.projectName=MobEAD"
                }
            }
        }

        stage('Deploy - Ambiente de Desenvolvimento') {
            steps {
                echo 'Iniciando container de Desenvolvimento...'
                script {
                    sh 'docker rm -f mobead-dev || true'
                    
                    sh 'docker run -d -p 8081:80 --name mobead-dev mobead-app:${BUILD_ID}'
                }
            }
        }

        stage('Aprovação para Produção') {
            steps {
                input message: 'O ambiente de Dev está OK. Alexandre, você aprova o deploy em Produção?', ok: 'Aprovar Deploy'
            }
        }

        stage('Deploy - Ambiente de Produção') {
            steps {
                echo 'Iniciando container de Produção...'
                script {
                    sh 'docker rm -f mobead-prod || true'
                    
                    sh 'docker run -d -p 8082:80 --name mobead-prod mobead-app:${BUILD_ID}'
                }
            }
        }
    }

    post {
        success {
            echo "======================================================"
            echo "✅ PIPELINE PIPELINE-ALEXANDRE EXECUTADA COM SUCESSO!"
            echo "======================================================"
        }
        failure {
            echo "❌ Falha na execução da pipeline."
        }
    }
}

pipeline {
    agent any
    environment{
        BUILD_NUMBER="${env.build_number}"
        GIT_COMMIT="${env.GIT_COMMIT.take(7)}"
        FRONTEND_IMAGE='sujeeeth29/employee_project_fe'
        BACKEND_IMAGE='sujeeeth29/employee_project_be'
        VERSION="${BUILD_NUMBER}_${GIT_COMMIT}"
    }
    stages{
        stage('Clean WS'){
            steps{
                cleanWs()
            }
        }
        stage('Checking Variables'){
            steps{
                script{
                    echo "Build number: ${BUILD_NUMBER}"
                    echo "GIT Commit: ${GIT_COMMIT}"
                    echo "Frontend Image: ${FRONTEND_IMAGE}:${BUILD_NUMBER}_${GIT_COMMIT}"
                    echo "Backend Image: ${BACKEND_IMAGE}:${BUILD_NUMBER}_${GIT_COMMIT}"
                }
            }
        }
        stage('Build Images'){
            steps{
                sh "VERSION=${VERSION} docker compose -f docker-compose-app.yml build"
            }
        }
    }
}
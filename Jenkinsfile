pipeline {
    agent any
    environment{
        BUILD_NUMBER="${env.build_number}"
        GIT_COMMIT="${env.GIT_COMMIT.take(7)}"
        VERSION="${BUILD_NUMBER}_${GIT_COMMIT}"
        FRONTEND_IMAGE="sujeeeth29/employee_project_fe:${VERSION}"
        BACKEND_IMAGE="sujeeeth29/employee_project_be:${VERSION}"
    }
    stages{
        stage('Clean WS'){
            steps{
                cleanWs()
                checkout scm
            }
        }
        stage('Checking Variables'){
            steps{
                script{
                    echo "Build number: ${BUILD_NUMBER}"
                    echo "GIT Commit: ${GIT_COMMIT}"
                    echo "Frontend Image: ${FRONTEND_IMAGE}:${BUILD_NUMBER}_${GIT_COMMIT}"
                    echo "Backend Image: ${BACKEND_IMAGE}:${BUILD_NUMBER}_${GIT_COMMIT}"
                    echo "Version: ${VERSION}"
                }
            }
        }
        stage('Check docker compose version'){
            steps{
                sh 'docker compose version'
            }
        }
        stage('Build Images'){
            steps{
                sh "FRONTEND_IMAGE=${FRONTEND_IMAGE} BACKEND_IMAGE=${BACKEND_IMAGE} VERSION=${VERSION} docker compose -f docker-compose.yml build emp_frontend emp_backend"
            }
        }
        // stage('Run Application'){
        //     steps{

        //     }
        // }
    }
}
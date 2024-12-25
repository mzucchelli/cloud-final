Project Summary:

This project is a tracker application for tracking stock trades. It utilizes
a microservices architecture.  Contained in the project is a frontend and backend
microservice. The project also uses AWS Cognito to handle account creation and authentication
as an additional microservice. Also, a Postgres database is used. This will run in docker-compose
or kubernetes.

The Frontend is a React Application, and the Backend is an API. the Frontend communicates with
AWS Cognito to facilitate account creation, and authenticaion. The Frontend also contains
a data grid for displaying trades, as well as Create, Edit, and Delete functionality.

The Backend is an API that the Frontend interacts with to provide the CRUD functionality, and is
protected by validating a JWT accessToken.

The Backend communicates with a Postgres server. If you are running locally using docker-compose, 
for development, the Postgres server will be spun up locally, the Kubernetes deployment will use
an AWS hosted Postgres server.

The integration tests are in the tests directory. Please refer to the README there for running the tests
after you have the application up and running.

How to run the application:

1. Set up AWS Cognito. The users created in cognito should sign in with email address and password. Access Tokens should be able to be granted.
   Create the settings accordingly.
    1. Create a new User Pool in AWS cognito and save the user pool ID for later
    2. Within that user pool, create an App client and save the app id for later

2. For Kubernetes deployments only, create a Postgres DB within AWS RDS (keep in mind the networking and the security group inbound rules so you 
   can access from your local docker-compose environment, or your k8s cluster).

3. To deploy locally (mainly for development)
    1. Enter the deployment/docker directory
    2. Copy env.template to .env.
        1. Only replace the values where specified
        2. The Postgres user, password, and DB name will be generated
           for your local environment, so when running locally, you don't
           have to know them ahead of time, you decide what they will be now
    3. In the two yaml files, replace mzucc with your own DockerHub name
    4. Build your containers
       # docker-compose -f docker-compose-build.yaml build
    5. Run your containers
       # docker-compose -f docker-compose.yaml up
    6. Sign into the application locally:
       http://localhost:5173
    7. Create a new user for yourself, and sign in
    8. Test the application by creating, updating, and deleting a stock trade.
    9. Run the integration tests (view the README inside the tests directory)

Connect your repository to TravisCI for builds. Create environment variables within Travis CI
Replace mzucc in the .travis.yml file with your dockerhub username
cd deployment/k8s
Copy env-configmap.yaml.template to env-configmap.yaml. Copy env-secret.yaml.template to env-secret.yaml.  Use this new files for your personal deploys
eksctl create cluster -f cluster-setup/cluster-config.yaml
Enter values in env-configmap.yaml for AWS_REGION, AWS_COGNITO_USERPOOLID, and AWS_COGNITO_CLIENT_ID
Create a postgres database in RDS with self managed credentials. Make sure your EKS cluster can communicate with it. Update your env-configmap and env-secret yaml files with the information to accessing your Postgres database
kubectl apply -f ingressClass.yaml
kubectl apply -f backend-ingress.yaml
kubectl apply -f frontend-ingress.yaml
Obtain the frontend domain name and backend domain name with
# kubectl get ingress
Update the API_URL and URL environment variables in env-configmap with these domain names (keep the ports as they are)
In TravisCI, create the following environment variables with the values you entered in your env-configmap: API_URL, AWS_COGNITO_CLIENTID, AWS_COGNITO_USERPOOLid, AWS_REGION
In TravisCI, create a DOCKER_USERNAME and DOCKER_PASSWORD environment variable with your dockerhub credentials
Trigger your first build. The environment variables must be set in travis before the build because the frontend is a production build with the values baked in from the webpack
When complete, update the image in your 2 deployment yaml's with the build number that just completed and was pushed to your dockerhub (it's in the tag). Also, replace mzucc with your dockerhub username
kubectl apply -f env-secret.yaml
kubectl apply -f env-configmap.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

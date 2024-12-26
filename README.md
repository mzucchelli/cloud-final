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
an AWS hosted Postgres server with RDS.

The integration tests are in the tests directory. Please refer to the README there for running the tests
after you have the application up and running.

I am currently hosting the application at the URL below using AWS EKS. Feel free to create an account and try it:

http://k8s-default-frontend-4ca52dc992-1689536412.us-east-1.elb.amazonaws.com:5173/

See the screenshots directory for screenshots of the deployed application, successful build, dockerhub, and 
passing postman tests.


----------------------------------------------------



How to run the application on your own:

1. Set up AWS Cognito. The users created in cognito should sign in with email address and password. Access Tokens should be able to be granted.
   Create the settings accordingly.
    1. Create a new User Pool in AWS cognito and save the user pool ID for later
    2. Within that user pool, create an App client and save the app id for later

2. For Kubernetes deployments only, create a Postgres DB within AWS RDS (keep in mind the networking and the security group inbound rules so you 
   can access from your k8s cluster - you could perform this step later, after you created your EKS cluster, and create it within the same VPC,
   or you could set up a new VPC now, and set up VPC peering later, or you could do it now and assign a public IP address and make sure the security
   group inbound rules are set up appropriately to recieve traffic from your cluster).

3. To deploy locally (mainly for development)
    1. Enter the deployment/docker directory
    2. Copy env.template to .env.
        1. Only replace the values where specified
        2. The Postgres user, password, and DB name will be generated
           for your local environment, so when running locally, you don't
           have to know them ahead of time, you decide what they will be now.
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

4. To deploy to kubernetes on AWS (for production)
   1. Set up the AWS CLI (if you are using AWS)
   2. Fork the repository, and connect your repository to TravisCI for builds. Create environment variables within Travis CI
   3. Replace mzucc in the .travis.yml file with your dockerhub username
      (this will also build in CircleCi, and will require slight changes to the yaml files)
   4. # cd deployment/k8s
   5. Copy env-configmap.yaml.template to env-configmap.yaml. Copy env-secret.yaml.template to env-secret.yaml.  Use this new files for your personal deploys
   6. Install the eksctl tool (or create your own k8s cluster a different way)
      # eksctl create cluster -f cluster-setup/cluster-config.yaml
   7. Enter values in env-configmap.yaml for AWS_REGION, AWS_COGNITO_USERPOOLID, and AWS_COGNITO_CLIENT_ID
   8. Create a postgres database in RDS with self managed credentials. Make sure your EKS cluster can communicate with it. Update your env-configmap and env-secret yaml files with the information to accessing your Postgres database
   9. The database won't be created automatically like it is in docker-compose, so install the postgres cli tools and create one with:
      # createdb -h <POSTGRES_HOST> -U <POSTGRES_USERNAME> -W <POSTGRES_DB>
   10. # kubectl apply -f ingressClass.yaml
   11. # kubectl apply -f backend-ingress.yaml
   12. # kubectl apply -f frontend-ingress.yaml
   13. Obtain the frontend domain name and backend domain name with
      # kubectl get ingress
   14. Update the API_URL and URL environment variables in env-configmap with these domain names (keep the ports as they are)
   15. In TravisCI, create the following environment variables with the values you entered in your env-configmap: API_URL, AWS_COGNITO_CLIENTID, AWS_COGNITO_USERPOOLid, AWS_REGION
   16. In TravisCI, create a DOCKER_USERNAME and DOCKER_PASSWORD environment variable with your dockerhub credentials
   17. Trigger your first build. The environment variables must be set in travis before the build because the frontend is a production build with the values baked in from the webpack (it is worth noting that the frontend-prod image in my dockerhub will only work with my AWS cluster because webpack hardcoded the environment variables in)
   18. When complete, update the image in your 2 deployment yaml's with the build number that just completed and was pushed to your dockerhub (it's in the tag). Update the number in this file with each build to ensure the most recent gets pulled. Could be useful to copy the file and put the version number in the file name and commmit, so you can easily deploy any version. Also, replace mzucc with your dockerhub username
   19. # kubectl apply -f env-secret.yaml
   20. # kubectl apply -f env-configmap.yaml
   21. # kubectl apply -f backend-deployment.yaml
   22. # kubectl apply -f backend-service.yaml
   23. # kubectl apply -f frontend-deployment.yaml
   24. # kubectl apply -f frontend-service.yaml
   25. # kube get pods
   26. As soon as all pods are running, visit your application (URL wil be the same as the URL environment variable in your config map)
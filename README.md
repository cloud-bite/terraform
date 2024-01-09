## OBJECTIVES:

- [x] Create group GCP project.
- [x] Create a Google Cloud Source Repository git repo and use it for the project together.
- [x] Fork this project to your own repositories and work in those together for the rest of the steps.
- [x] Invite team members to the project with relevant IAM roles assigned.
- [x] Create Terraform landing zone (initialize Terraform, connect with GCP backend) use Terraform for the next steps where it makes sense.
- [ ] Create build pipeline for frontend and backend applications.
- [ ] Change frontend app so that the backend address comes from configuration.
- [ ] Deploy frontend application to Storage Bucket with web settings and publish it with CDN.
- [x] Deploy backend application to Cloud Run.
- [ ] Use Secret Manager to store database sensitive information.
- [x] Create Cloud SQL MySQL instance.
- [ ] Create secure connection between Cloud Run backend and the deployed MySQL instance.
- [ ] Implement generative AI, that generates food images, stores them in a bucket and shows as the menu items (e.g. by acquiring images with a Cloud Function).
- [ ] Implement centralised logging and alerting on key metrics for the whole stack.

## STEPS OF IMPLEMENTATION:
Going through the setup-steps of our solution, the first and most important step is allocating a bucket for storing the terraform state in the relevant GCP project. In the same file the required providers are set, in order to direct the terraform commands to the right place. This is done in the 00-main.tf-file, along with the setting of the three project variables; the gcp project, the gcp region, and the gcp zone.

The second step in the process is setting up the SQL instance running in the project, responsible for receiving the orders sent by the frontend through the backend. The instance is added to the VPN where both the front- and backend are otherwise hosted. A private IP address is added to the instance making it accessible for the backend to query. Private (and random) credentials are added to the 02-sql.tf-file, in order to create a variable to use in setting the root user for the SQL instance. From here a Google hosted MySQL database is spun up, in order to host the data related to the application. The database is hosted on the same network as the other instances. Finally a root user is created for the database, along with some network connectivity configurations.

The third step in the process is related to setting up the backend of the project, meaning the actual driving force behind the application we are meant to implement. We need to implement a way for the backend to interact with the resources located on the database, and on the further VPC. From here we implement the actual backend, through the cloud run service. The database variables necessary to gain access to the actual database are injected into an env-file running on the service. The backend URL is exported, to be provided to the frontend. Finally we also create a binding to the secret manager to get the actual env-variables from the secret manager.

The fourth step is the frontend, responsible for creating both the storage bucket for storing the website, as well as allowing for reader access to the pages present.

The fifth step is the content distribution network, responsible for hosting the actual website (frontend) the users of the application are to interact with. We initiate the document by setting a global address for the website. From here we create a bucket for storing the files needed by the website, which are distributed by the CDN. The frontend is then mapped to the backend, in terms of handling the requests made. We finally forward our solution, based on some standard rules (the port being 80, using TCP, as well as where the forwarding should point). 

Finally in the sixth step, we initialize the secrets used throughout the project, and set the variables for using the database (the host, the name, the password, and the user).

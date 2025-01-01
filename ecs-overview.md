Checklist for Deploying an Application to ECS
Below is a concise yet detailed breakdown of essential components for deploying to AWS ECS:

1. Application Code & Dockerfile
    • Purpose: Define your application logic and dependencies. The Dockerfile packages everything needed to run your app in containers.

2. Amazon ECR
    • Purpose: Securely store and manage Docker images for ECS to use during deployment.

3. ECS Task Definitions
    • Purpose: Specify container configurations, including the image, CPU/memory, networking, and environment variables.

4. ECS Services
    • Purpose: Maintain and scale ECS tasks, ensuring the application is always running and integrated with load balancers.

5. Virtual Private Cloud (VPC)
    • Purpose: Provide a secure and isolated network for application resources with control over routing and connectivity.

6. Subnets
    • Purpose:
        ○ Public Subnets: Host resources needing internet access, like ALBs.
        ○ Private Subnets: Protect ECS tasks from direct internet exposure.

7. Internet Gateway (IGW)
    • Purpose: Enable internet access for public subnet resources.

8. NAT Gateway
    • Purpose: Allow private subnet resources (like ECS tasks) to securely access the internet.

9. Route Tables
    • Purpose: Define traffic flow within the VPC, including routes for internet access via IGW or NAT Gateway.

10. Security Groups
    • Purpose: Control inbound and outbound traffic for ECS tasks, ALBs, and other resources.

11. Application Load Balancer (ALB)
    • Purpose: Distribute traffic to ECS tasks, manage HTTPS, and perform health checks.

12. Target Groups
    • Purpose: Route traffic from the ALB to ECS tasks and monitor their health.

13. Listeners
    • Purpose: Define ALB rules to route incoming traffic to target groups (e.g., redirect HTTP to HTTPS).

14. Amazon Certificate Manager (ACM)
    • Purpose: Secure traffic with SSL/TLS certificates for HTTPS.

15. IAM Roles
    • Purpose: Grant ECS tasks permissions for AWS services like ECR, S3, and CloudWatch.

16. Ingress & Egress Rules
    • Purpose:
        ○ Ingress: Allow traffic into ECS tasks (e.g., ALB to ECS).
        ○ Egress: Allow ECS tasks to communicate with other resources (e.g., databases).

17. Auto Scaling
    • Purpose: Automatically adjust ECS tasks based on load for optimal resource utilisation and cost efficiency.

18. Monitoring & Logging
    • Purpose: Use CloudWatch for logs and metrics to monitor ECS performance and troubleshoot issues.

19. External DNS Integration
    • Purpose: Route traffic to the ALB using a user-friendly domain name via services like Route 53 or Cloudflare.

20. Cost Optimisation
    • Purpose: Minimise costs by optimising resources like ECS tasks, NAT Gateways, and ALBs.

21. Environment Variables
    • Purpose: Securely pass configuration data to ECS tasks.

22. Infrastructure as Code (IaC)
    • Purpose: Automate resource provisioning using tools like Terraform or CloudFormation for consistent and repeatable deployments.

23. Health Checks
    • Purpose: Ensure ECS tasks are operational before routing traffic to them.

Start with the Application: Cloning and Preparing the Code
Before diving into infrastructure or containerisation, the very first step is to select an application you'd like to deploy. This could be something that solves a specific problem or, in my case, a game that offers a fun challenge for users. I chose the chess game application because it was a unique opportunity to work on something engaging while showcasing my DevOps skills.

Step 1: Cloning the Application Repositories
    • Choose an Application: Start by identifying an application that aligns with your learning goals or interests. For me, the chess game was perfect because it involved both front-end interactivity and back-end logic, making it an excellent candidate for deployment.
    • Clone the Repositories:
        ○ Clone the application logic repository, such as Chess.js, which provides the game mechanics.
        ○ Clone the interface library, such as Chessboard.js, which provides the user interface.
        ○ For example:

bash
Copy code
git clone https://github.com/jhlywa/chess.js.git
git clone https://github.com/oakmac/chessboardjs.git
    • Why Clone to Your Own Repo?
        ○ Cloning directly from the original repository is a great way to get started, but it's best practice to fork the repository and push the code to your own GitHub repository. This ensures that any modifications you make don’t affect the original project.

bash
Copy code
git clone https://github.com/<your-username>/your-chess-game-repo.git
    • Link to Your Repository: Once you’ve cloned the code locally, push it to your own GitHub repository.
        ○ This step helps maintain clean version control for your project while keeping the original repository intact.

bash
Copy code
git remote add origin https://github.com/<your-username>/your-chess-game-repo.git
git push -u origin main

Step 2: Customise and Extend the Application
Once the code is in your repository:
    • Customise the App: Modify the application to suit your goals. For example, I integrated AI opponents into the chess game to enhance its functionality and user experience.
    • Organise File Structures: Rename directories or files to reflect the changes you've made. For instance, I updated directory names to chessai.js and chessboardai to represent the AI-enhanced game logic and interface.

Step 3: Testing Locally
Before moving to the next stage, always test your application locally:
    • Install dependencies with npm install or yarn.
    • Run the application with node server.js and ensure it functions as expected.
    • Use debugging tools like browser "Inspect" to identify and resolve any issues early in the process.

Why This Step is Crucial
Starting with a well-tested application ensures that your deployment is focused on infrastructure and automation rather than fixing application issues later. Cloning and pushing to your own repository helps maintain the integrity of the original code while giving you flexibility to experiment, extend, and learn.


The Journey to a Fully Functional Chess Game with AI Opponents (LOCALLY)
When I first ran the chess game locally, it felt like things were off to a great start—the header "Simple Chess Game" displayed perfectly. But there was a significant problem: the chessboard itself was missing. Using the browser's "Inspect" tool and reviewing the console, I discovered that the file paths to Chessboard.js and Chess.js were incorrect. Updating these references in the index.html file fixed the issue, and the chessboard finally appeared.
Feeling a sense of accomplishment, I ran the app again, only to face another challenge—the chess pieces were missing. Diving into the Chessboard.js configuration, I noticed it was trying to fetch image files from a non-existent directory. After updating the image file paths, the board came to life with all the pieces in place.
However, the hurdles weren’t over yet. As I tested the game, I realised I was playing against myself—there was no AI opponent to compete against. This defeated the entire purpose of the game! To solve this, I decided to integrate an AI opponent. Leveraging Chess.js's move calculation capabilities, I added logic for the AI to respond intelligently to player moves, creating a more engaging and competitive experience.
This transformation also required some organisational changes. To better represent the new AI functionality, I renamed the chess.js directory to chessai.js and updated chessboard to chessboardai. These updates not only aligned with the game's enhanced functionality but also made the structure more intuitive for future maintenance.
Throughout this process, I learned the power of systematically troubleshooting issues. Using tools like "Inspect," I was able to pinpoint missing file paths and debug errors efficiently. This hands-on debugging experience gave me newfound confidence in identifying and fixing problems, turning challenges into opportunities to refine and improve the application.
Finally, after addressing every issue, the game came to life. The player could make their move and watch the AI counter strategically, creating a fully functional and immersive chess experience. Each problem I encountered, from missing pieces to AI integration, was a step toward transforming the app into a complete and polished project.

Challenges with the Dockerfile and Improvements Made (DOCKER)
One of the early challenges I faced was getting the chess game application to run properly in the Docker container. While everything worked perfectly on my local machine now, the game wouldn’t run in the container. After some investigation, I realised that the Dockerfile wasn’t configured correctly:
    • Not all required files and dependencies were being copied into the container.
    • The WORKDIR and environment setup in the Dockerfile weren’t properly aligned with the application structure.
    • The node_modules directory was being rebuilt in the container, causing conflicts.
To resolve this, I reworked the Dockerfile:
    1. I ensured the COPY statements included all the necessary files, such as the server.js, package.json, and index.html, alongside other dependencies.
    2. I corrected the WORKDIR setup so that all commands and file references were relative to the correct directory.
    3. I tested the updated Docker image locally using docker run to confirm it worked as expected before pushing it to AWS Elastic Container Registry (ECR).
These changes ensured the chess game was containerised correctly and could run seamlessly in any environment.



How the Deployment Cogs Work Together: The Sequential Process
Deploying the chess game on AWS ECS using Terraform required each component to be configured and linked in a specific sequence. Here’s how the entire process worked, step by step:

1. Application Preparation: Define, Test, and Containerise
    • Start Point: Before any infrastructure was set up, the application itself needed to be ready.
    • Steps:
        1. Define the Dockerfile:
            § Create a Dockerfile to define how the app should be packaged. This includes specifying the base image, copying the application files, and defining how the app should run (e.g., using CMD ["node", "server.js"]).
        2. Build and Test Locally:
            § Test the application locally using node server.js to ensure there are no bugs.
            § Build the Docker image using docker build and test it locally with docker run.
        3. Tag and Push to ECR:
            § Tag the image with the ECR repository name using docker tag.
            § Push the image to AWS ECR, making it accessible for deployment.

2. Infrastructure Setup: Build the Backbone
    • Start Point: With the Docker image pushed to ECR, it’s time to build the infrastructure using Terraform.
    • Steps:
        1. S3 and DynamoDB for State Management:
            § Create an S3 bucket to store the Terraform state file and a DynamoDB table for state locking.
            § Configure Terraform to use this backend to ensure state consistency.
        2. VPC and Subnets:
            § Define the VPC to host the resources.
            § Create public subnets for the Application Load Balancer (ALB) and private subnets for ECS tasks.
        3. ALB Configuration:
            § Deploy the ALB in the public subnets.
            § Configure listeners for HTTP/HTTPS traffic and link them to target groups.

3. Compute Setup: Deploy the App
    • Start Point: With the network and ALB ready, the ECS resources can now be deployed.
    • Steps:
        1. ECS Cluster:
            § Create the ECS cluster to host the tasks.
        2. Task Definition:
            § Define the task to use the Docker image from ECR.
            § Specify CPU, memory, and port mappings.
        3. ECS Service:
            § Link the ECS service to the ALB target group.
            § Set the desired number of tasks to ensure high availability.

4. Secure and Expose the App
    • Start Point: With ECS tasks running, secure the application and make it accessible to users.
    • Steps:
        1. ACM Certificates:
            § Request and validate an SSL certificate for HTTPS traffic.
            § Attach the certificate to the ALB’s HTTPS listener.
        2. Cloudflare DNS:
            § Update Cloudflare DNS records to point to the ALB DNS name, linking the custom domain to the application.

Flow of Operation
Here’s how all the pieces work together in action:
    1. A user sends a request to the app’s domain (managed by Cloudflare).
    2. The request is routed to the ALB via its public DNS name.
    3. The ALB checks its target group and forwards the request to an ECS task running in a private subnet.
    4. The ECS task pulls the Docker image from ECR and starts the container.
    5. The application processes the request, communicates with any necessary back-end services (like databases), and returns the response.
    6. The ALB forwards the response back to the user, completing the cycle.

Why the Sequence Matters
This sequential approach ensures:
    • Testing First: The app works locally and in Docker before deploying.
    • Stable Infrastructure: The network and ALB are ready to handle traffic before tasks are launched.
    • Secure Access: Certificates and DNS settings are configured to ensure users access the app securely.
By following this logical flow, the chess game was successfully deployed with minimal issues, scalable infrastructure, and a secure, user-friendly interface.





Setting Up Terraform State with Cost Efficiency in Mind
Another challenge was when I accidentally pushed the .terraform directory, including the state file, to my Git repository. This was a key learning moment since the state file contains sensitive information and shouldn’t be version controlled. It also highlighted the need for a better way to manage Terraform state securely.
To address this, I set up an S3 bucket and DynamoDB table for managing the Terraform state:
    • The S3 bucket stores the Terraform state file securely, while the DynamoDB table handles state locking to prevent conflicts during deployments.
    • I updated the .gitignore file to exclude the .terraform directory and any state files, ensuring they would no longer be tracked in Git.
    • Importantly, I configured the S3 bucket and DynamoDB table in a way that wouldn’t incur unnecessary costs. The S3 bucket only generates charges if files are stored, and the DynamoDB table only incurs costs when it’s actively accessed during deployments.
Additionally, I ensured these resources weren’t destroyed when running terraform destroy, as keeping them in place allows for future deployments without having to set them up again.
These adjustments not only improved security and organisation but also ensured cost efficiency, which is critical for managing cloud infrastructure effectively. It was a valuable lesson in balancing best practices with practical constraints.

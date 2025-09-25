# maybank-cloud-dev

Maybank Cloud Developer Take Home Assessment

## Running this project

This project is already equipped with a fully functioning CI/CD pipeline.

Only need to input these with correct values in the workflow:
- Account ID
- TF state bucket name
- Region
- arn:aws:iam::${{ inputs.accountId }}:role/GithubOIDC role creation

## Folders

- deploy/
  - Terraform for AWS infrastructure.
  - Top-level resources include VPC subnets, EKS cluster, NLB, RDS, S3, bastion, and app servers.
  - modules/
    - app/: App-related infra (e.g., EFS and app wiring).
    - edge/: Edge networking/ingress-related infra.
    - eks/: EKS cluster, IAM, and outputs.
    - subnets/: VPC subnet definitions and outputs.

- helm/
  - Helm charts for deploying workloads onto the Kubernetes cluster.
  - sample-app/: Example chart with service, ingress (NGINX), HPA, PVC/StorageClass (EFS), etc.


## Potential Improvements

- Security Groups can be more secured and granular
- Introduce NACL rules & WAF rules
- Network Policy for Namespace
- Load Balancer Ingress
- Remote Secrets manager 
- Terminate TLS on NLB
- etc
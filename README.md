# Terraform Fundamentals - Assignment 5

Hands-on practice with HashiCorp's official **AWS Get Started** Terraform tutorials, run in my own AWS Free Tier account. Each tutorial has its own folder, and every lab follows the same Terraform workflow: `init` -> `plan` -> `apply` -> `destroy`.

## Table of contents

1. [What is used](#what-is-used)
2. [Prerequisites](#prerequisites)
3. [Repository structure](#repository-structure)
4. [Terraform workflow](#terraform-workflow)
5. [Common files](#common-files-used-in-the-labs)
6. [Labs](#labs)
7. [Useful commands](#useful-commands)
8. [Troubleshooting](#troubleshooting)
9. [Security and cost control](#security-and-cost-control)

---

## What is used

| Item | Details |
|---|---|
| Tool | Terraform (HashiCorp) |
| Language | HCL (HashiCorp Configuration Language) |
| Cloud | AWS (Free Tier account) |
| AWS Region | `ap-south-1` (Mumbai) |
| Provider | `hashicorp/aws`, version `~> 5.92` |
| OS image (AMI) | Ubuntu 24.04 LTS, found automatically with a `data` block (Canonical, owner `099720109477`) |
| Instance type | `t3.micro` |
| Remote state | Amazon S3 bucket (versioning on) with S3 state locking (`use_lockfile = true`) |
| Registry module | `terraform-aws-modules/vpc/aws` |
| Credentials | Set with `aws configure` (stored outside this repo) |

---

## Prerequisites

1. AWS account with the AWS CLI configured (use region `ap-south-1`):
```
   aws configure
```
2. Terraform installed. Check with:
```
   terraform -version
```
   Terraform **1.10 or newer** is needed for `use_lockfile` in the S3 backend lab.
3. Git installed.

---

## Repository structure

```
Terraform-Practice/
├── .gitignore
├── README.md
├── lab1/   (Tutorial 03 - Build Infrastructure)
├── lab2/   (Tutorial 04 - Change Infrastructure)
├── lab3/   (Tutorial 05 - Destroy Infrastructure)
├── lab4/   (Tutorial 06 - Input Variables)
├── lab5/   (Tutorial 07 - Outputs)
├── lab6/   (Tutorial 08 - Remote State, S3 backend)
├── lab7/   (Tutorial 09 - Create a Module)
├── lab8/   (Tutorial 10 - Modules from the Registry)
└── lab9/   (Tutorial 11 - Terraform Versions and Providers)
```

Tutorials 1 and 2 are concept and installation tutorials, so they have no code folder.

---

## Terraform workflow

```
 Write code (.tf files)
        |
        v
 terraform init      -> downloads the provider / modules
        |
        v
 terraform plan      -> previews what will be created, changed or destroyed
        |
        v
 terraform apply     -> creates / updates the real AWS resources
        |
        v
 terraform destroy   -> removes everything Terraform created
```

---

## Common files used in the labs

| File | Purpose |
|---|---|
| `terraform.tf` | Terraform settings: required Terraform version and required providers (and the backend in lab6) |
| `main.tf` | Main configuration: provider, AMI lookup, and resources |
| `variables.tf` | Input variables (values that can be changed without editing resources) |
| `outputs.tf` | Output values printed after `apply` |
| `.terraform.lock.hcl` | Locks the exact provider versions (created by `terraform init`, committed to Git) |

Created by Terraform but **not** committed (in `.gitignore`): `.terraform/` folder, `terraform.tfstate`, `terraform.tfstate.backup`.

---

## Labs

### 1. What is Infrastructure as Code with Terraform
- **Type:** Concept tutorial (no code)
- **What I learned:** Infrastructure as Code means describing servers, networks and other resources in files instead of clicking in the AWS console. The files can be stored in Git, reviewed and reused.
- **Key learning:** IaC makes infrastructure repeatable and trackable.

### 2. Install Terraform
- **Type:** Setup tutorial (no code)
- **What I did:** Installed Terraform and verified it with `terraform -version`.
- **Key learning:** Terraform is a single command-line tool that talks to cloud providers through plugins.

### 3. Build Infrastructure - `lab1`
- **What it does:** Creates one EC2 instance (Ubuntu 24.04, `t3.micro`) in `ap-south-1` with the tag `Name = learn-terraform`.
- **Files:** `terraform.tf`, `main.tf`
- **Run:**
```
  cd lab1
  terraform init
  terraform plan
  terraform apply
  terraform destroy
```
- **Expected result:** `Apply complete! Resources: 1 added.` and the instance is visible in the AWS Console (EC2 > Instances).
- **Key learning:** `init` downloads the provider, `plan` previews, `apply` creates. The `data` block finds the latest Ubuntu AMI, so I don't hardcode an AMI ID.

### 4. Change Infrastructure - `lab2`
- **What it does:** Creates the same EC2 instance, then I change its `Name` tag and apply again.
- **Files:** `terraform.tf`, `main.tf`
- **Run:**
  1. `terraform init`, then `terraform apply` (tag is `learn-terraform`)
  2. Edit `main.tf`: change the tag to `learn-terraform-updated`
  3. `terraform apply` again
  4. `terraform destroy`
- **Expected result:** The second apply shows `1 changed` (an in-place update, not a new instance).
- **Key learning:** Terraform compares my code with the real infrastructure and only changes the difference.

### 5. Destroy Infrastructure - `lab3`
- **What it does:** Creates the EC2 instance, then removes it completely.
- **Files:** `terraform.tf`, `main.tf`
- **Run:**
```
  cd lab3
  terraform init
  terraform apply
  terraform destroy
```
- **Expected result:** `Destroy complete! Resources: 1 destroyed.` and the instance shows as *Terminated* in the AWS Console.
- **Key learning:** `terraform destroy` removes everything Terraform created, which keeps the account clean and avoids charges.

### 6. Define Input Variables - `lab4`
- **What it does:** Same EC2 instance, but the instance name and instance type come from variables instead of being hardcoded.
- **Files:** `terraform.tf`, `main.tf`, `variables.tf`
- **Run:**
```
  cd lab4
  terraform init
  terraform apply
  terraform apply -var "instance_name=my-custom-name"   # optional: override a variable
  terraform destroy
```
- **Expected result:** The instance name tag matches the variable value.
- **Key learning:** Variables make the same code reusable with different values.

### 7. Query Data with Outputs - `lab5`
- **What it does:** Adds an output that prints the instance's private DNS name after apply.
- **Files:** `terraform.tf`, `main.tf`, `variables.tf`, `outputs.tf`
- **Run:**
```
  cd lab5
  terraform init
  terraform apply
  terraform output
  terraform destroy
```
- **Expected result:** `terraform output` prints `instance_hostname`.
- **Key learning:** Outputs show useful values after apply and can pass data to other configurations.

### 8. Store Remote State (S3 Backend) - `lab6`
- **What it does:** Stores the Terraform state file in an S3 bucket instead of on my laptop, and uses S3 state locking.
- **Files:** `terraform.tf` (contains the `backend "s3"` block), `main.tf`, `variables.tf`, `outputs.tf`
- **Backend block (in `terraform.tf`):**
```hcl
  terraform {
    required_version = ">= 1.10"

    backend "s3" {
      bucket       = "<your-unique-bucket-name>"
      key          = "learn-terraform/terraform.tfstate"
      region       = "ap-south-1"
      encrypt      = true
      use_lockfile = true
    }
  }
```
- **State locking:** I use `use_lockfile = true`, which keeps the lock in S3 itself (a `.tflock` file next to the state file while Terraform runs). The older DynamoDB locking (`dynamodb_table`) is deprecated by HashiCorp, so no DynamoDB table is used.
- **Setup (the bucket must exist before `terraform init`):**
```
  aws s3api create-bucket --bucket <your-unique-bucket-name> --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
  aws s3api put-bucket-versioning --bucket <your-unique-bucket-name> --versioning-configuration Status=Enabled
```
  Bucket versioning is turned on so an old state can be recovered after an accidental deletion or mistake. The bucket name must be globally unique and must match the name in `terraform.tf`.
- **Run:**
```
  cd lab6
  terraform init        # answer yes if it asks to copy state
  terraform apply
  terraform state list
  terraform destroy
```
- **Expected result:** The state file appears inside the S3 bucket (S3 > bucket > `learn-terraform/terraform.tfstate`). The lock file only exists while Terraform is running.
- **Key learning:** Remote state is safer and shareable than a file on my laptop. Locking stops two runs from changing the state at the same time.
- **Cleanup:** After `terraform destroy`, empty and delete the S3 bucket from the AWS Console if it is no longer needed.

### 9. Create a Terraform Module (bonus) - `lab7`
- **What it does:** Uses a module to build a VPC with subnets, and places the EC2 instance in a private subnet.
- **Files:** `terraform.tf`, `main.tf`, `variables.tf`, `outputs.tf`
- **Run:** `terraform init`, `terraform apply`, `terraform destroy`
- **Key learning:** A module groups resources into reusable code that takes inputs.

### 10. Use Modules from the Registry - `lab8`
- **What it does:** Uses the public `terraform-aws-modules/vpc/aws` module from the Terraform Registry. Availability zones are set to `ap-south-1a`, `ap-south-1b`, `ap-south-1c`.
- **Files:** `terraform.tf`, `main.tf`, `variables.tf`, `outputs.tf`
- **Run:**
```
  cd lab8
  terraform init       # downloads the module from the registry
  terraform apply
  terraform destroy
```
- **Expected result:** A VPC and subnets are visible in the AWS Console (VPC > Your VPCs).
- **Key learning:** Registry modules give ready-made infrastructure, so I only set the inputs instead of writing every resource.

### 11. Manage Terraform Versions and Providers (bonus) - `lab9`
- **What it does:** Shows how version constraints control which Terraform and provider versions are allowed.
- **Files:** `terraform.tf`, `main.tf`
- **Run:**
```
  cd lab9
  terraform init
  terraform version
  terraform providers
  terraform destroy
```
- **Key learning:** `required_version` and the provider `version` constraint make sure the code only runs with compatible versions, and `.terraform.lock.hcl` locks the exact provider version.

---

## Useful commands

| Command | What it does |
|---|---|
| `terraform init` | Downloads providers and modules, sets up the backend |
| `terraform fmt` | Formats the code neatly |
| `terraform validate` | Checks the code for syntax errors |
| `terraform plan` | Previews the changes |
| `terraform apply` | Creates or updates resources |
| `terraform destroy` | Deletes resources |
| `terraform state list` | Lists the resources Terraform is tracking |
| `terraform show` | Shows the current state in readable form |
| `terraform output` | Prints the output values |
| `terraform version` | Shows the Terraform and provider versions |
| `terraform providers` | Shows which providers the configuration uses |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `No valid credential sources found` | Run `aws configure` and check the access key and region |
| `BucketAlreadyExists` | S3 bucket names are global, so choose a more unique name |
| `Backend configuration changed` | Run `terraform init -reconfigure` (or `-migrate-state` to move existing state) |
| `Error acquiring the state lock` | Another run is still going, or an earlier run crashed. Wait, or use `terraform force-unlock <LOCK_ID>` only if you are sure nothing is running |
| Availability zone error in the module labs | Make sure the `azs` match the region (`ap-south-1a`, `ap-south-1b`, `ap-south-1c`) |
| Instance type not allowed | Use a Free Tier eligible instance type for your account (this repo uses `t3.micro`) |

---

## Security and cost control

- AWS access keys are **not** stored in this repo (they are set with `aws configure`).
- `.gitignore` excludes `.terraform/`, `*.tfstate`, `*.tfstate.*`, `*.tfvars`, `*.pem`, `*.key` and `.env`.
- `.terraform.lock.hcl` **is** committed because it only holds version information.
- `terraform destroy` was run after every lab so no resources are left running in the AWS account.

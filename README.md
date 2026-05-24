# AWS Infrastructure with Terraform

This project provisions a highly available web infrastructure on AWS using Terraform. It sets up a custom VPC, two public subnets across different Availability Zones, EC2 web servers, an S3 bucket, and an Application Load Balancer (ALB) to distribute traffic between the instances.

---

## Architecture Overview

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │  ALB (HTTP) │
                    └──────┬──────┘
               ┌───────────┴───────────┐
               ▼                       ▼
     ┌─────────────────┐     ┌─────────────────┐
     │  EC2 (web1)     │     │  EC2 (web2)     │
     │  ap-south-1a    │     │  ap-south-1b    │
     │  subnet1        │     │  subnet2        │
     └─────────────────┘     └─────────────────┘
               └───────────┬───────────┘
                    ┌──────▼──────┐
                    │  Custom VPC │
                    │ 10.0.0.0/16 │
                    └─────────────┘
```

---

## Resources Created

| Resource | Name | Description |
|---|---|---|
| `aws_vpc` | main-vpc | Custom VPC with configurable CIDR |
| `aws_subnet` | subnet1 | Public subnet in `ap-south-1a` (`10.0.0.0/24`) |
| `aws_subnet` | subnet2 | Public subnet in `ap-south-1b` (`10.0.1.0/24`) |
| `aws_internet_gateway` | my-igw | Internet Gateway attached to the VPC |
| `aws_route_table` | rt | Route table with a default route to the IGW |
| `aws_security_group` | websg | Allows inbound SSH (22) and HTTP (80), all outbound |
| `aws_s3_bucket` | example | S3 bucket for storing project assets |
| `aws_instance` | web1 | EC2 instance in subnet1, bootstrapped via userdata.sh |
| `aws_instance` | web2 | EC2 instance in subnet2, bootstrapped via userdata1.sh |
| `aws_lb` | my-alb | Public-facing Application Load Balancer |
| `aws_lb_target_group` | my-target-group | Target group with HTTP health checks on `/` |
| `aws_lb_listener` | mylistener | ALB listener on port 80, forwards to target group |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate credentials
- An AWS account with permissions to create VPC, EC2, S3, and ELB resources
- A valid EC2 AMI ID for your target region (default config uses `ap-south-1`)

---

## Project Structure

```
.
├── main.tf           # All AWS resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output values (ALB DNS, instance IDs, etc.)
├── userdata.sh       # Bootstrap script for web1 EC2 instance
├── userdata1.sh      # Bootstrap script for web2 EC2 instance
└── README.md
```

---

## Variables

| Variable | Description | Default |
|---|---|---|
| `vpc_cidr` | CIDR block for the VPC | e.g. `10.0.0.0/16` |

Define them in a `terraform.tfvars` file:

```hcl
vpc_cidr = "10.0.0.0/16"
```

---

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview the execution plan

```bash
terraform plan
```

### 4. Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted. After a successful apply, the ALB DNS name will be shown in the outputs — open it in a browser to verify the setup.

### 5. Destroy the infrastructure

```bash
terraform destroy
```

---

## Security Group Rules

| Type | Port | Protocol | Source |
|---|---|---|---|
| Ingress | 22 | TCP | `0.0.0.0/0` |
| Ingress | 80 | TCP | `0.0.0.0/0` |
| Egress | All | All | `0.0.0.0/0` |

> **Note:** The SSH rule is open to all IPs (`0.0.0.0/0`) for demonstration purposes. In production, restrict this to your own IP.

---

## Health Check Configuration

The ALB target group performs HTTP health checks on `/`:

| Parameter | Value |
|---|---|
| Protocol | HTTP |
| Path | `/` |
| Expected status | `200–299` |
| Interval | 30 seconds |
| Timeout | 5 seconds |
| Healthy threshold | 2 consecutive checks |
| Unhealthy threshold | 2 consecutive checks |

---

## Notes

- Both subnets are in **different Availability Zones** (`ap-south-1a` and `ap-south-1b`), which is required for the ALB to function correctly.
- The S3 bucket name (`jatinterraform-s3-bucket1897`) must be globally unique — update it in `main.tf` before applying.
- The AMI ID (`ami-07a00cf47dbbc844c`) is region-specific. Replace it with a valid AMI for your target region.
- EC2 instances use `user_data_base64` to run bootstrap scripts on first launch via `userdata.sh` and `userdata1.sh`.

---

## License

This project is open source and available under the [MIT License](LICENSE).

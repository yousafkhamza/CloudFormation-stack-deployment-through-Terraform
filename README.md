# CloudFormation-stack-deployment-through-Terraform

[![Build](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

---
## Description
I just try to write a CloudFormation Stack with EC2 instance & Security Group. So, this is a combined infrastructure deployment using AWS CloudFormation with Terraform. Also, you guys have a doubt why used both at the same time. Because I just tried to deploy a CloudFormation stack through Terraform. Hence, we can avoid AWS manual CloudFormation selection and related steps as well, and also, we can simply use the same in a CI/CD pipeline and easy to add or change things through Terraform. 

Furthermore, you can use that CloudFormation code directly through the AWS console so, then you can skip Terraform that if you don't need it. In addition, I had provided both console and terraform steps in README so please read the same and do with good practice.

#### Brief
----
AWS CloudFormation Sample Template EC2InstanceWithSecurityGroupSample:   Create an Amazon EC2 instance running the Amazon Linux AMI. The AMI is chosen based on the region in which the stack is run. This example creates an EC2 security group for the instance to give you SSH access. **WARNING** This template creates an Amazon   EC2 instance. You will be billed for the AWS resources used if you create a stack from this template. Also, I repeat the template deployment using both manual and terraform automated.

----
## Feature
- Easy to deploy ec2 instance and security group using CF template
- Easy to deploy CF stack through terraform 
- Region-wise AMI fetching automatically

----
## Pre-Requests
- Existing an instance keypair
- Basic Knowledge of Terraform
- Basic Knowledge of CloudFormation (YAML)
- [AWS Access Key and Secret Key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

#### Installations
##### Terraform
----
- Linux: (Please note that only for Linux no need to download any repo or files)
```
curl -Ls https://raw.githubusercontent.com/yousafkhamza/Terraform_installation/main/terraform.sh | bash
```

- [Installation Guide for others](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

##### Git
------
- Linux
```
yum install -y git
```
- [Installation Guide for others](https://github.com/git-guides/install-git)

-----
## How to Get
```
git clone https://github.com/yousafkhamza/CloudFormation-stack-deployment-through-Terraform
```
----
## How to use with Terraform
> **Please make sure you have entered the Access key, Secret key (or either IAM role attached), and Instance keypair name so please verify terrform.tfvars and provider.tf file before as well**

```
cd CloudFormation-stack-deployment-through-Terraform
```
_terraform.tfvars_
```
aws_region = "us-east-1"    # mention which region would you need.
key_name = "owntest"        # this one is for study purposes so you guys mention here the existing key pair name under your AWS account which you using.
instance_type = "t2.micro"  # mention which instance type would you need.
cf_file = "./ec2stack.yml"  # CF stack file. so, if you have any ec2 instance and security group-related changes? then please go and change the same as CF format because that file doesn't have any dependencies with terraform.
```
_provider.tf_   [`if you're using IAM role you can skip the credential passing`]
```
provider "aws" {
region = var.aws_region
access_key = your access_key
secret_key = your secret_key
}
```
### Terraform Execution
```
terraform init
terraform plan
terraform apply
```

----
## Output be like
```
[ec2-user@ip-172-31-11-179 CloudFormation-stack-deployment-through-Terraform]$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudformation_stack.ec2_instance will be created
  + resource "aws_cloudformation_stack" "ec2_instance" {
      + id            = (known after apply)
      + name          = "ec2-instance-stack"
      + outputs       = (known after apply)
      + parameters    = {
          + "InstanceType" = "t2.micro"
          + "KeyName"      = "owntest"
        }
      + policy_body   = (known after apply)
      + tags          = {
          + "Name" = "CF-EC2-Stack"
        }
      + tags_all      = {
          + "Name" = "CF-EC2-Stack"
        }
      + template_body = <<-EOT
            # Date: 08/12/2021
            # Author: Yousaf K Hamza
            # Description: CloudForamtion Stack creation with EC2 instance and Security Group in a YAML Format

            # ----------------------------------------------------
            # CloudFormation Stack in YAML
            # ----------------------------------------------------
            AWSTemplateFormatVersion: '2010-09-09'
            Description: 'AWS CloudFormation Sample Template EC2InstanceWithSecurityGroupSample:
              Create an Amazon EC2 instance running the Amazon Linux AMI. The AMI is chosen based
              on the region in which the stack is run. This example creates an EC2 security group
              for the instance to give you SSH access. **WARNING** This template creates an Amazon
              EC2 instance. You will be billed for the AWS resources used if you create a stack
              from this template.'

            # ----------------------------------------------------
            # Parameters like as we can pass values like variables
            # ----------------------------------------------------
            Parameters:
              KeyName:
                Description: Name of an existing EC2 KeyPair to enable SSH access to the instance
                Type: AWS::EC2::KeyPair::KeyName
                ConstraintDescription: must be the name of an existing EC2 KeyPair.
              InstanceType:
                Description: WebServer EC2 instance type
                Type: String
                ConstraintDescription: must be a valid EC2 instance type.
              SSHLocation:
                Description: The IP address range that can be used to SSH to the EC2 instances
                Type: String
                MinLength: 9
                MaxLength: 18
                Default: 0.0.0.0/0
                AllowedPattern: (\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/(\d{1,2})
                ConstraintDescription: must be a valid IP CIDR range of the form x.x.x.x/x.
              LatestAmiId:
                Type:  'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
                Default: '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2'

            # ----------------------------------------------------
            # Resource Creation for EC2
            # ----------------------------------------------------
            Resources:
              EC2Instance:
                Type: AWS::EC2::Instance
                Properties:
                  InstanceType: !Ref 'InstanceType'
                  SecurityGroups: [!Ref 'InstanceSecurityGroup']
                  KeyName: !Ref 'KeyName'
                  ImageId: !Ref 'LatestAmiId'
                  Tags:
                    - Key: Name
                      Value: CF-EC2

            # ----------------------------------------------------
            # Resource Creation for Security group
            # ----------------------------------------------------
              InstanceSecurityGroup:
                Type: AWS::EC2::SecurityGroup
                Properties:
                  GroupDescription: Enable SSH access via port 22
                  SecurityGroupIngress:
                  - IpProtocol: tcp
                    FromPort: 22
                    ToPort: 22
                    CidrIp: !Ref 'SSHLocation'

            # ----------------------------------------------------
            # After stack creation outputs act like a terraform output
            # ----------------------------------------------------
            Outputs:
              InstanceId:
                Description: InstanceId of the newly created EC2 instance
                Value: !Ref 'EC2Instance'
              AZ:
                Description: Availability Zone of the newly created EC2 instance
                Value: !GetAtt [EC2Instance, AvailabilityZone]
              PublicDNS:
                Description: Public DNSName of the newly created EC2 instance
                Value: !GetAtt [EC2Instance, PublicDnsName]
              PublicIP:
                Description: Public IP address of the newly created EC2 instance
                Value: !GetAtt [EC2Instance, PublicIp]
        EOT
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_cloudformation_stack.ec2_instance: Creating...
aws_cloudformation_stack.ec2_instance: Still creating... [10s elapsed]
aws_cloudformation_stack.ec2_instance: Still creating... [20s elapsed]
aws_cloudformation_stack.ec2_instance: Still creating... [30s elapsed]
aws_cloudformation_stack.ec2_instance: Still creating... [40s elapsed]
aws_cloudformation_stack.ec2_instance: Still creating... [50s elapsed]
aws_cloudformation_stack.ec2_instance: Still creating... [1m0s elapsed]
aws_cloudformation_stack.ec2_instance: Still creating... [1m10s elapsed]
aws_cloudformation_stack.ec2_instance: Creation complete after 1m16s [id=arn:aws:cloudformation:us-east-1:361738388880:stack/ec2-instance-stack/0803bf10-58de-11ec-88bf-12fb6e4d7bd1]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

----
## How to use CloudFormation stack without Terraform
_Screenshot 1_
![alt_txt](https://i.ibb.co/hKg0TVD/1.png)

_Screenshot 2_
![alt_txt](https://i.ibb.co/2dYzgTh/2.png)

_Screenshot 3_
![alt_txt](https://i.ibb.co/VSWmH3h/3.png)

_Screenshot 4_

![alt_txt](https://i.ibb.co/T4dN4YG/4.png)

_Screenshot 5_
![alt_txt](https://i.ibb.co/Pmk7Ft5/5.png)

----
## Behind the code
_ec2stack.yml_
```
# ----------------------------------------------------
# CloudFormation Stack in YAML
# ----------------------------------------------------
AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS CloudFormation Sample Template EC2InstanceWithSecurityGroupSample:
  Create an Amazon EC2 instance running the Amazon Linux AMI. The AMI is chosen based
  on the region in which the stack is run. This example creates an EC2 security group
  for the instance to give you SSH access. **WARNING** This template creates an Amazon
  EC2 instance. You will be billed for the AWS resources used if you create a stack
  from this template.'

# ----------------------------------------------------
# Parameters like as we can pass values like variables
# ----------------------------------------------------
Parameters:
  KeyName:
    Description: Name of an existing EC2 KeyPair to enable SSH access to the instance
    Type: AWS::EC2::KeyPair::KeyName
    ConstraintDescription: must be the name of an existing EC2 KeyPair.
  InstanceType:
    Description: WebServer EC2 instance type
    Type: String
    ConstraintDescription: must be a valid EC2 instance type.
  SSHLocation:
    Description: The IP address range that can be used to SSH to the EC2 instances
    Type: String
    MinLength: 9
    MaxLength: 18
    Default: 0.0.0.0/0
    AllowedPattern: (\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/(\d{1,2})
    ConstraintDescription: must be a valid IP CIDR range of the form x.x.x.x/x.
  LatestAmiId:
    Type:  'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
    Default: '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2'

# ----------------------------------------------------
# Resource Creation for EC2
# ----------------------------------------------------
Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref 'InstanceType'
      SecurityGroups: [!Ref 'InstanceSecurityGroup']
      KeyName: !Ref 'KeyName'
      ImageId: !Ref 'LatestAmiId'
      Tags:
        - Key: Name
          Value: CF-EC2

# ----------------------------------------------------
# Resource Creation for Security group
# ----------------------------------------------------
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable SSH access via port 22
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 22
        ToPort: 22
        CidrIp: !Ref 'SSHLocation'

# ----------------------------------------------------
# After stack creation outputs act like a terraform output
# ----------------------------------------------------
Outputs:
  InstanceId:
    Description: InstanceId of the newly created EC2 instance
    Value: !Ref 'EC2Instance'
  AZ:
    Description: Availability Zone of the newly created EC2 instance
    Value: !GetAtt [EC2Instance, AvailabilityZone]
  PublicDNS:
    Description: Public DNSName of the newly created EC2 instance
    Value: !GetAtt [EC2Instance, PublicDnsName]
  PublicIP:
    Description: Public IP address of the newly created EC2 instance
    Value: !GetAtt [EC2Instance, PublicIp]
```

_main.tf_
```
# ----------------------------------------------------
# CloudFormation Stack
# ----------------------------------------------------
resource "aws_cloudformation_stack" "ec2_instance" {
  name = "ec2-instance-stack"

  parameters = {
    KeyName = var.key_name
    InstanceType = var.instance_type
  }
  template_body = file("${var.cf_file}")

  tags = tomap({"Name" = "CF-EC2-Stack"})
}
```

----
## Referance
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-instance.html
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack
- https://octopus.com/blog/aws-cloudformation-ec2-examples

----
## Conclusion
This is a combined infrastructure deployment using AWS CloudFormation and Terraform. and it's created for a try how to use hybrid deployment of IaC (Terraform, CloudFormation) 

### ⚙️ Connect with Me 


<p align="center">
<a href="mailto:yousaf.k.hamza@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"/></a>
<a href="https://www.linkedin.com/in/yousafkhamza"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/></a> 
<a href="https://www.instagram.com/yousafkhamza"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white"/></a>
<a href="https://wa.me/%2B917736720639?text=This%20message%20from%20GitHub."><img src="https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white"/></a><br />

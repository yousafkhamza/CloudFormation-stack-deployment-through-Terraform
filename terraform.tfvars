aws_region = "us-east-1"    # mention which region would you need/
key_name = "owntest"        # this one is for study purpose so you guys mention here existing keypair name on under your aws account which you using.
instance_type = "t2.micro"  # mention which instance type would you need.
cf_file = "./ec2stack.yml"  # CF stack file so if you have any ec2 instance and security group changes please go and change the same as CF format that file haven't any dependancies with terraform

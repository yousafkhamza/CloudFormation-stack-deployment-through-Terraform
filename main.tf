# Date: 08/12/2021
# Author: Yousaf K Hamza
# Description: CloudForamtion stack terraform sample

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

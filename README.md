## Terraform - AWS VPC [![Build Status](https://travis-ci.org/onaio/terraform-aws-vpc.svg?branch=master)](https://travis-ci.org/onaio/terraform-aws-vpc)

This module brings up a Virtual Private Cloud on AWS.

Check [variables.tf](./variables.tf) for a list of variables that can be set for this module.


# INPUTS

| Variable                                  | Description                           |  Default
| ----------------------------------------- | ------------------------------------- | ----------- | 
| allow_private_subnets_access_to_internet  | Creates nat gateway and add routes to it to allow ec2 to the private subnets internet                               | false       | 
| create_private_subnets                    | Creates subnets with no route to Internet Gateway.  | false       |    
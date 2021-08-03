About the Project:

The goal of this project is to provison aws ec2 instances with ubuntu 18.04. It has a user data script that will install puppet 5.4.0.  It also have an associated github workflow that will provision the serve once you push your code to main repositry. We have used github secrets to pass aws secret key and access key as a enviornment variable. 

Usage:

To use this project, create two secrets in github secrets, once this secrets are created pass these secrets to the yaml file, and push you code. This will create an ec2 instane with puppet installed on it.

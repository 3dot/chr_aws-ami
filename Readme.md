# Mikrotik RouterOS Cloud Hosted Router (CHR) AMI

Create and publish an AWS Amazon Machine Image (AMI) to your account in order to launch the latest version of RouterOS on EC2

## Overview
The official [Mikrotik CHR AMI](https://aws.amazon.com/marketplace/pp/prodview-sf5gn6js6av54) is stuck on RouterOS v6 for some time now, and using the upgrade process to v7 inside a RouterOS v6 deployed on EC2 [can result in a bricked instance](https://forum.mikrotik.com/viewtopic.php?t=187597).

This repository contains the automated GitHub Actions process of creating a custom AMI for the RouterOS version defined in `version.txt`. The AMIs published here are available in the `eu-central-1` region when searching for `Mikrotik CHR` in the AMI community images search.

## Create your own AMI
While using the AMI created by this process is perfectly fine (the RouterOS image is published as an AMI as is, without changes), it is not good practice for production usage. Therefore it is best to clone this repository and publish the AMIs to your own AWS account and the regions needed.

TODO: The exact step by step process of setting up the AWS account and GitHub actions

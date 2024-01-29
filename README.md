# poc-platform-eks-base 


## Introduction 

This repository contains Terraform code to install EKS Cluster


## What Plugins are installed ?

## How are the plugins installed ?

## How are NIFI workflows backed up and restored 

## How is the elastic cluster backed up and restored ?

The below are the following steps thats executed as part of the Github Actions Pipeline 

* Register hot snapshot repository
* Register partial snapshot repository
* Register cold snapshot repository
* Apply ILM and Index template
* Create an index template and attach the policy to the template
* Restore

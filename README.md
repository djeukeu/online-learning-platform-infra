# Automated Cloud-Native Microservice Deployment with Terraform & Kubernetes

This project is a microservice application which uses Terraform to provision cloud resources and Kubernetes for container orchestration.

## 🚀 Project Description

It consists of three main microservices:

* [Auth Service:](https://github.com/djeukeu/online-learning-platform-auth) A user management and authentication service that uses a MySQL database.
* [Course Service:](https://github.com/djeukeu/online-learning-platform-course) Manages courses, lessons, and related data using a PostgreSQL database.
* [Payment Service:](https://github.com/djeukeu/online-learning-platform-payment) Handles payments and transactions using a PostgreSQL database.

The Terraform project provisions AWS EKS and three RDS instances, as well as the supporting networking, IAM and Helm configurations needed to run the microservices.

The Kubernetes project isolates each service with its own deployment and database connection, and provides a clusterIP for internal communication between services. To make the services available externally, the kubernetes project was separated into two environments: development and production. The development environment uses Nginx Ingress to route traffic to the correct services, and the production environment uses AWS ALB for external exposure.

## 📌 Diagrams

![System Architecture Diagram](https://github.com/djeukeu/online-learning-platform-infra/blob/master/microservice-1.png)

![Application Traffic Flow](https://github.com/djeukeu/online-learning-platform-infra/blob/master/microservice-2.png)
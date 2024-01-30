# Netflix Clone DevOps

> Projeto de CI/CD completo para disponibilização de uma aplicação Django (ecommerce) por meio de um cluster Kubernetes no EKS.

## 💻 Funcionalidades

- Manifestos terraform para deploy do cluster Amazon EKS (`./terraform`)
  - Instalação do Cert-Manager e NGINX Ingress Controller
- Aplicação completa em JS (`./django-ecommerce`)
- Manifestos Kubernetes Ingress, Deployment e Service (`./kubernetes`)
- Pipeline CI/CD Github Actions
  - Aplicação dos Manifestos Kubernetes
  - Criação do apontamento DNS na Cloudflare conforme endereço do Ingress

## 💻 Pré-requisitos

Antes de começar, verifique se você atendeu aos seguintes requisitos:

- Conta na AWS
- Instalação do Terraform
- Deploy local da Infraestrutura 

## 🚀 Instalação

Para instalar o projeto, siga estas etapas:

```
git clone https://github.com/matheus-nicolay/django-ecommerce-devops
cd terraform
```
```bash
vi provider.auto.tfvars

#Escrever credenciais da AWS:
#region      = "us-east-1"
#access_key  = "key"
#secret_key  = "secret"
```
```
terraform init
terraform apply
```

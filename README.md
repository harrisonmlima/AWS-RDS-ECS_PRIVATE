# AWS-RDS-ECS_PRIVATE
## Antes de executar o terraform, lembrar que você deve criar o ECR manualmente, por causa da demora no push do docker image para a aws, ai por questões de custo, resolvi deixar separado. Então quando criar o ECR e fizer o push da imagem, pegar o URI e alterar a string de nome IMAGEM, no arquivo main.tf

## Caso queira pegar a imagem docker do projeto, pegar no repositorio harrisonlima/kube-news:v1

## Before execute the terraform, remember that you must create ECR manually, because of the waiting to push the docker image to aws, so for cost reasons, i decided to leave it separate. When you have created you ECR and pushed your docker image, take the URI and change the string of name IMAGEM in the main.tf file.

## In case you want to take the docker image of the project, take it in the repository harrisonlima/kube-news:v1
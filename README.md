# Tech interview backend entry level main
## RD Station Cart Challenge API

API REST desenvolvida em Ruby on Rails para gerenciamento de carrinho de compras de um e-commerce, com suporte a background jobs para limpeza automática de carrinhos abandonados.

## Como Executar o Projeto

A aplicação está totalmente dockerizada. Para facilitar a execução, o projeto inclui um **Makefile** que detecta automaticamente sua versão do Docker Compose.

### 1. Setup Inicial
Execute o comando abaixo para construir os containers, criar os bancos de dados (dev e test) e popular com os seeds:

```bash
make setup
````

**O que este comando faz:**
* Builda as imagens Docker.
* Sobe os serviços de dependência (Postgres e Redis).
* Cria, migra e popula o banco de desenvolvimento.
* Cria e migra o banco de testes.

### 2. Rodar a Aplicação
Após o setup, inicie a API e o Sidekiq:

```bash
make server
````

### 3. Rodando os Testes
A suíte de testes utiliza RSpec.

```bash
make test
````

### 4. Outros Comandos Úteis

```bash
make console: Acessa o Rails Console dentro do container.

make shell: Acessa o terminal (bash) do container.

make clean: Derruba os containers e remove os volumes (limpeza total).
````

## Alternativa Manual (sem Make)
Caso prefira rodar os comandos do Docker manualmente:


### 1. Subir os serviços
```bash
docker-compose up -d --build
````
### 2. Configurar o Banco
```bash
docker-compose exec web bin/rails db:create db:migrate db:seed
````
### 3. Rodar o servidor (caso não tenha subido)
```bash
docker-compose up
````
### 4. Rodar os testes
```bash
docker-compose exec web bundle exec rspec
````

## Carrinhos Abandonados (Background Jobs)

A aplicação possui um Job agendado (**MarkCartAsAbandonedJob**) que roda
automaticamente a cada hora para:

-   Marcar como abandonado carrinhos sem interação há mais de **3
    horas**.
-   Remover carrinhos abandonados há mais de **7 dias**.

### Monitoramento

Você pode visualizar o agendamento e a execução dos Jobs através do
painel do Sidekiq:

-   **Dashboard:** http://localhost:3000/sidekiq
-   **Agendamento (Cron):** http://localhost:3000/sidekiq/recurring-jobs

------------------------------------------------------------------------

##  Documentação da API
Carrinho

| Método | Rota                | Descrição                                                      |
| ------ | ------------------- | -------------------------------------------------------------- |
| GET    | `/cart`             | Retorna o carrinho atual da sessão.                            |
| POST   | `/cart`             | Adiciona um item ao carrinho (cria o carrinho se não existir). |
| POST   | `/cart/add_item`    | Incrementa a quantidade de um item existente.                  |
| DELETE | `/cart/:product_id` | Remove um item do carrinho.                                    |


### Guia de Testes Manuais (cURL)
Esta API utiliza sessões (session[:cart_id]), portanto os exemplos abaixo utilizam cookies.txt para manter a persistência entre requisições.

Importante: Caso os IDs do seu banco sejam diferentes de 1, 2 ou 3 (devido a testes anteriores), você pode resetar o banco (docker-compose run --rm web bin/rails db:migrate:reset db:seed) ou consultar a lista atualizada abaixo.

#### 0. Consultar IDs dos Produtos
Antes de começar, liste os produtos disponíveis no banco para confirmar quais IDs utilizar:

```bash
docker-compose run --rm web bin/rails runner "puts Product.all.pluck(:id, :name).map { |p| p.join(' - ') }"
````

#### 1. Adicionar Item ao Carrinho
Adiciona o produto ID 1 (ajuste conforme a lista acima) ao carrinho.

```bash
curl -i -c cookies.txt -H "Content-Type: application/json" \
  -X POST -d '{"product_id": 1, "quantity": 1}' \
  http://localhost:3000/cart
```

#### 2. Consultar Carrinho
Recupera o carrinho atual enviando o cookie da sessão.

```bash
curl -i -b cookies.txt -H "Content-Type: application/json" \
  http://localhost:3000/cart
````

#### 3. Adicionar Outro Item
Adiciona o produto ID 2 ao mesmo carrinho.

```bash
curl -i -b cookies.txt -c cookies.txt -H "Content-Type: application/json" \
  -X POST -d '{"product_id": 2, "quantity": 3}' \
  http://localhost:3000/cart/add_item
````

#### 4. Remover Item
Remove o produto ID 1 do carrinho.

```bash
curl -i -b cookies.txt -c cookies.txt -H "Content-Type: application/json" \
  -X DELETE \
  http://localhost:3000/cart/1
````

#### 5. Monitoramento (Sidekiq)
Acesse o painel para visualizar os Jobs em execução:

URL: http://localhost:3000/sidekiq

## Exemplo de Payload (Adicionar Item)

**POST /cart**

``` json
{
  "product_id": 1,
  "quantity": 2
}
```


# Desafio técnico e-commerce

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

A API estará disponível em: http://localhost:3000

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

-   **Dashboard:** http://localhost:3000/sidekiq\
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

## Exemplo de Payload (Adicionar Item)

**POST /cart**

``` json
{
  "product_id": 1,
  "quantity": 2
}
```

------------------------------------------------------------------------

## Tecnologias e Decisões Técnicas

* **Ruby 3.3.1 / Rails 7.1.3**
* **PostgreSQL 16**: Banco de dados relacional.
* **Redis 7**: Armazenamento para processamento de filas e cache.
* **Sidekiq + Sidekiq Scheduler**: Escolhido para o processamento de background jobs devido à sua robustez e facilidade de monitoramento via Web UI.
* **Docker & Docker Compose**: O ambiente foi totalmente containerizado para garantir consistência entre desenvolvimento e teste.

### Destaques da Implementação
* **Performance:** Utilização de `update_all` e `destroy_all` nos Jobs para otimizar operações em lote no banco de dados. No payload do carrinho, foi utilizado `.includes(:product)` para prevenir consultas N+1.
* **Arquitetura:** Lógica de negócio encapsulada no Model (`Cart`), mantendo o Controller ("Skinny Controller") responsável apenas pela orquestração HTTP.
* **Idempotência:** O arquivo `seeds.rb` e os métodos de criação utilizam `find_or_create_by` para garantir que scripts possam ser reexecutados sem duplicar dados.

---
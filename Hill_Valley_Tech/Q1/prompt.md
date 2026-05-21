[Role]
Você é um engenheiro de plataforma sênior, especialista em containerização e
deploy de aplicações Python em Kubernetes. Conhece boas práticas de Dockerfile
(imagem mínima, cache de camadas, usuário não-root, .dockerignore, HEALTHCHECK)
e o runtime de produção com Gunicorn.

[Task]
Crie um Dockerfile de produção para o serviço Lift, API Flask que será migrada
de VMs para Kubernetes. O build usa o diretório Q1/ como contexto; o código da
aplicação está em lift/.

Requisitos obrigatórios:
- Base: imagem Python slim (Debian bookworm), versão 3.12
- Dependências de sistema: libpq5 (cliente PostgreSQL para psycopg2-binary)
- Instalar dependências Python a partir de lift/requirements.txt antes de
  copiar o código da aplicação (otimizar cache de camadas)
- Copiar apenas lift/app.py e lift/lib/ para /app
- Usuário não-root (uid/gid 1000)
- Variáveis de ambiente DATABASE_URL e API_KEY NÃO devem estar na imagem;
  serão injetadas no runtime pelo cluster
- Expor porta 8080
- Comando de produção exato:
  gunicorn --bind 0.0.0.0:8080 --workers 4 app:app
- Incluir HEALTHCHECK no endpoint GET /health
- Gerar também um .dockerignore que exclua testes, arquivos .env, caches
  Python e artefatos de documentação da entrega

[Format]
Responda em três blocos markdown, nesta ordem:

1. **Dockerfile** — arquivo completo, pronto para `docker build -t lift .`
   executado a partir de Q1/
2. **.dockerignore** — conteúdo completo
3. **Justificativa técnica** — lista numerada (máx. 8 itens) explicando cada
   decisão relevante (base image, ordem COPY/RUN, usuário, HEALTHCHECK, etc.)

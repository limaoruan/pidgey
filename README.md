# PIDgey 1.4

Site **público** da PokéBottons para consulta do código PID do botton. Site estático (PWA, mobile first) feito por Ruan Oliveira Lima, hospedado no **GitHub Pages**, com consulta ao banco no **Supabase**.

Esta pasta é a **raiz de um repositório** no GitHub (`pidgey`).

---

## O que faz

O cliente digita o código PID do botton e vê: PID, produto, arte, marca, frente, traseira, fixação, diâmetro, espessura, peso, Lote, Item, "Feito em" e "Entregue em", com o botão **Copiar dados**.

- Não mostra preço nem dados do caixa.
- A consulta só fica disponível depois que o botton é entregue (pode levar até 24 horas). Botton não entregue aparece como "PID não encontrado".
- O público só consegue executar a função `consultar_pid` do banco; nada mais.

### De onde vêm os dados
- **Do banco:** PID, arte, Lote, Item, "Feito em" e "Entregue em".
- **Escritos no `index.html`:** Produto (Broche Personalizado), Marca (PokéBottons), Frente (Metal), Traseira (Plástico Branco), Fixação (Alfinete), Diâmetro (37mm), Espessura (6mm) e Peso (4g). Para mudar algum deles, edite o arquivo.

## Como usar
1. Digite o PID do botton. A máscara `PID-000-000-000/00` é preenchida sozinha e aceita 11 dígitos.
2. Toque em **Buscar**. Se o botton foi entregue há pouco, aguarde até 24 horas.
3. Toque em **Copiar dados** para copiar o resultado, uma linha "Rótulo: valor" por campo. O botão mostra "Copiado!" ou "Não foi possível copiar".
4. Use o **×** do campo para limpar a busca.

**Link direto:** abrir o site com `?pid=` na frente do código faz a busca sozinha, por exemplo `https://limaoruan.github.io/pidgey/?pid=PID-000-000-000/00`. Serve para colocar em um QR code.

**Mensagens:** "Formato inválido. Use PID-000-000-000/00.", "PID não encontrado.", "Não foi possível consultar agora. Tente novamente." e "Sem conexão. Tente novamente.". O site abre sem internet, mas a consulta exige conexão.

## Instalação

### 1. Banco de dados
O PIDgey usa o **mesmo projeto do Supabase** do PokéPOS. A ordem importa:
1. Se ainda não fez, instale o PokéPOS primeiro (projeto no Supabase e o `setup_supabase.sql` dele): ele cria as tabelas.
2. Depois, no **SQL Editor**, cole todo o `setup_supabase.sql` desta pasta e execute **uma única vez**. Ele cria só a função `consultar_pid`, que lê a tabela `bottons`, e libera o público para chamá-la.

Se o setup do PokéPOS não tiver sido executado, este para com um aviso.

### 2. Configurar o site
- Em `config.js`, troque `SUPABASE_URL` e `SUPABASE_CHAVE` pela Project URL e pela chave **publishable** (ou **anon**) do mesmo projeto, em **Project Settings**, **API Keys**.
- Essa chave pode ficar no repositório público: quem protege os dados é o banco. **Nunca** use a chave `secret` ou `service_role`.
- Se for publicar em outra conta do GitHub, troque `limaoruan` pelo seu usuário em `index.html`, `robots.txt`, `sitemap.xml` e `LICENCE.md`.

### 3. Publicar no GitHub Pages
1. Crie um repositório **público** chamado `pidgey`.
2. Envie todo o conteúdo desta pasta para a raiz do repositório, O arquivo `.nojekyll` é opcional.
3. Em **Settings**, **Pages**, escolha **Deploy from a branch**, branch `main`, pasta `/ (root)`.
4. Aguarde alguns minutos. O endereço será https://limaoruan.github.io/pidgey/

### 4. Testar
1. Abra o endereço e digite o PID de um botton já entregue; deve aparecer "Botton encontrado".
2. Se ainda não configurou, crie a tarefa do cron-job.org descrita em **Manutenção**.

### 5. Instalar como app (opcional)
Os sites são PWA. No celular, abra o endereço do site e use **Adicionar à tela inicial**:
- **Android:** menu do navegador, **Instalar app** ou **Adicionar à tela inicial**.
- **iPhone:** botão **Compartilhar**, **Adicionar à Tela de Início**.

## Manutenção
O plano gratuito do Supabase pausa o projeto após cerca de 7 dias com pouca atividade no banco de dados. Para evitar isso, uma tarefa agendada no **cron-job.org** (gratuito) consulta o PID de teste `PID-000-000-000/00` (função `consultar_pid`, criada pelo `setup_supabase.sql` deste projeto) várias vezes ao dia. O Supabase pede "algumas requisições por dia" ao banco. Configure uma vez:
1. Rode antes o `setup_supabase.sql` deste projeto, se ainda não rodou (ele cria a `consultar_pid`).
2. Crie uma conta em https://cron-job.org e, em **Cronjobs**, clique em **Create cronjob**.
3. **URL:** `SUA_URL_DO_SUPABASE/rest/v1/rpc/consultar_pid` (a URL é a `SUPABASE_URL` do `config.js`).
4. **Agendamento:** a cada 4 horas.
5. Em **Advanced**: método de requisição `POST`; cabeçalhos `apikey: SUA_CHAVE_PUBLISHABLE`, `Authorization: Bearer SUA_CHAVE_PUBLISHABLE` e `Content-Type: application/json`; corpo `{"p_pid":"PID-000-000-000/00"}`. A chave é a `SUPABASE_CHAVE` do `config.js` (a publishable, nunca a secret).
6. Salve e use **Test run**: o esperado é status 200. A resposta pode ser `null` se esse botton ainda não foi entregue, e isso não é erro.
- Se o projeto pausar mesmo assim, abra-o no painel do Supabase e clique em **Resume project** (o aviso por e-mail chega cerca de 1 semana antes). Depois confira o **History** da tarefa no cron-job.org.
- O PokéPOS e o PIDgey usam o mesmo projeto do Supabase, então esta única tarefa serve para os dois.
- Para atualizar o site, edite os arquivos no repositório; o GitHub Pages publica sozinho em alguns minutos.

## Arquivos
- `index.html`: o site inteiro (HTML, CSS e JavaScript)
- `config.js`: URL e chave publishable do Supabase
- `setup_supabase.sql`: cria a consulta pública `consultar_pid` (rode depois do setup do PokéPOS)
- `service-worker.js`, `manifest.webmanifest`: PWA
- `logo.png`, `icon-*.png`, `favicon*`, `apple-touch-icon.png`, `og-image.jpg`: imagens
- `LICENCE.md`: licença do projeto
- `robots.txt`, `sitemap.xml`, `.nojekyll`

## Segurança
- **Chave do `config.js`:** a chave **publishable** (ou **anon**) pode ficar no repositório público, porque quem protege os dados é o banco. **Nunca** coloque a chave `secret` ou `service_role`.
- **Consulta pública:** `consultar_pid` devolve só dados públicos de botton já entregue, sem preço e sem dados do Caixa.

---

© 2026 Ruan Oliveira Lima · Instagram: https://www.instagram.com/ruanoliveiralima_/
Licença: CC BY-SA 4.0 (texto completo no `LICENCE.md`)

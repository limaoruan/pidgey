# PIDgey 1.3

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

## Manutenção
O plano gratuito do Supabase pausa o projeto após cerca de 7 dias sem uso. O arquivo `.github/workflows/manter-supabase-ativo.yml` faz uma consulta pública de teste (`consultar_pid`, sem dados) 2 vezes por semana, às segundas e quintas, 00:00 no horário de Brasília, usando a URL e a chave do `config.js`. Para testar na hora, abra **Actions**, escolha **Manter Supabase ativo** e use **Run workflow**; o resultado verde confirma que o Supabase respondeu.
- Se o GitHub desativar o agendamento por falta de atividade no repositório, reative em **Actions**.
- Se o projeto pausar, use **Restore** no painel do Supabase.
- Para atualizar o site, edite os arquivos no repositório; o GitHub Pages publica sozinho em alguns minutos.

## Arquivos
- `index.html`: o site inteiro (HTML, CSS e JavaScript)
- `config.js`: URL e chave publishable do Supabase
- `setup_supabase.sql`: cria a consulta pública `consultar_pid` (rode depois do setup do PokéPOS)
- `.github/workflows/manter-supabase-ativo.yml`: consulta agendada
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

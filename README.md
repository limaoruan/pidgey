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
2. Se ainda não configurou, crie o monitor do Checkly descrito em **Manutenção** e rode o **Run test**.

### 5. Instalar como app (opcional)
Os sites são PWA. No celular, abra o endereço do site e use **Adicionar à tela inicial**:
- **Android:** menu do navegador, **Instalar app** ou **Adicionar à tela inicial**.
- **iPhone:** botão **Compartilhar**, **Adicionar à Tela de Início**.

## Manutenção
O plano gratuito do Supabase pausa o projeto após cerca de 7 dias com pouca atividade no banco de dados. Para evitar isso, um monitor gratuito no **Checkly** abre o PIDgey num navegador de verdade a cada 6 horas. Como o site faz a busca sozinha quando a URL tem `?pid=`, essa abertura consulta o banco (função `consultar_pid`) e conta como atividade. Configure uma vez:
1. Rode antes o `setup_supabase.sql` deste projeto, se ainda não rodou (ele cria a `consultar_pid`), e confirme que o site está publicado no GitHub Pages.
2. Crie uma conta gratuita (plano **Hobby**) em https://app.checklyhq.com/signup e crie um **Browser Check**.
3. Cole este script no check (troque `limaoruan.github.io/pidgey` pelo endereço do seu site, se for outro):

```js
import { test, expect } from '@playwright/test'

test('PIDgey consulta o Supabase', async ({ page }) => {
  const resposta = page.waitForResponse(r =>
    r.url().includes('/rest/v1/rpc/consultar_pid'))
  await page.goto('https://limaoruan.github.io/pidgey/?pid=PID-000-000-000/00')
  const r = await resposta
  expect(r.status()).toBe(200)

  const dados = await r.json()
  if (dados) {
    console.log('Botton encontrado')
    console.log('PID: ' + dados.pid)
    console.log('Lote: ' + dados.lote + ' | Item: ' + dados.item)
    console.log('Arte: ' + (dados.arte || ''))
    console.log('Fabricado em: ' + dados.fabricado_em)
    console.log('Entregue em: ' + dados.entregue_em)
  } else {
    console.log('Nenhum botton entregue com esse PID (resposta null).')
  }

  await page.waitForTimeout(1000)
  console.log('Resultado na tela do site: ' + (await page.locator('#out').innerText()))
})
```

4. Configure o check:
   - **Frequência:** a cada 6 horas.
   - **Localizações:** pode deixar uma ou mais, mas use **Round-robin** e deixe **Parallel runs** desligado. Assim roda em uma localização por vez, cerca de 120 execuções por mês, dentro das 1.000 gratuitas.
   - **Alertas:** ligue o e-mail com o seu endereço, para ser avisado se o check falhar.
5. Use **Run test** (o esperado é passar, em verde), clique em **Save** e confirme que o check está **ativado** e não silenciado (muted). O **Run test** sozinho não liga o agendamento.
6. Confira depois de 6 a 12 horas: o histórico do check deve mostrar execuções agendadas, a cada 6 horas, todas verdes. O log de cada execução mostra os dados do botton consultado; se o botton `000-000-000/00` ainda não foi entregue, o log diz "resposta null", e isso não é erro.
- Se o check falhar, o projeto provavelmente pausou: abra-o no painel do Supabase e clique em **Resume project** (o aviso por e-mail do Supabase chega cerca de 1 semana antes). Se aparecer erro de DNS, o endereço do Supabase ainda não voltou; espere alguns minutos.
- O PokéPOS e o PIDgey usam o mesmo projeto do Supabase, então este único monitor serve para os dois.
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

© 2026 Ruan Oliveira Lima · Instagram: https://www.instagram.com/limaoruan/
Licença: CC BY-SA 4.0 (texto completo no `LICENCE.md`)

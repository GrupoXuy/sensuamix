# SensuaMix — operação sem estoque próprio

## Modelo
A SensuaMix funciona como vitrine e canal de atendimento, sem comprar nem manter estoque próprio. Os produtos são fornecidos por parceiros que possuam pronta entrega e capacidade de despacho ao consumidor.

“Pronta entrega” significa disponibilidade real informada pelo parceiro e confirmada para a consulta/pedido. Não significa disponibilidade garantida só porque o item aparece no catálogo.

## Fluxo obrigatório
1. O cliente escolhe o produto e monta uma lista de interesse.
2. A SensuaMix consulta o parceiro e registra disponibilidade, preço, custo, moeda, frete, prazo, SKU e validade da cotação.
3. O cliente recebe o preço total, prazo, condições de envio e política de troca/devolução.
4. O cliente aprova as condições. Só então o pedido pode avançar para cobrança.
5. Após o pagamento confirmado, o parceiro separa e despacha o item.
6. A SensuaMix acompanha a expedição e informa o rastreio.

Se o parceiro não confirmar disponibilidade ou se a cotação expirar, não cobrar o cliente. Oferecer alternativa ou encerrar a solicitação.

## Regras de transparência
- Não mostrar quantidades como se fossem estoque próprio.
- Não usar os preços do estudo financeiro como preços vigentes.
- Não afirmar “disponível” sem confirmação atual do fornecedor.
- Informar moeda, preço total, frete, prazo, origem do envio e modalidade de despacho antes da cobrança.
- Prometer embalagem discreta somente quando confirmada para aquela remessa.
- Não cobrar antes da confirmação do parceiro e da aprovação expressa do cliente.

## Dados necessários
- Parceiro: dados comerciais, contato, aprovação, termos e capacidade de envio direto/embalagem discreta.
- Produto: categoria, descrição, medidas/tamanhos, materiais, imagem aprovada e estado de publicação.
- Oferta: SKU, disponibilidade, preço de custo, preço ao cliente, moeda, último horário de confirmação, validade, frete e prazo.
- Pedido: cliente, endereço de entrega, itens/preços aprovados, pagamento e histórico.
- Expedição: parceiro, transportadora, referência, código/link de rastreio e datas.

## Estado técnico desta versão
A interface tem catálogo, filtros, busca e lista de interesse local. A lista pode ser copiada, mas não gera pedido no servidor. Ainda não existe banco próprio SensuaMix, autenticação administrativa, cadastro persistente de fornecedores, checkout, pagamentos, cálculo de frete ou rastreio integrado.

O arquivo supabase/schema-draft.sql é somente uma proposta de estrutura com RLS e não foi aplicado. É necessário criar/selecionar um projeto Supabase exclusivo da SensuaMix e revisar custos e configurações antes de executar qualquer migração.

## Critérios antes de vender
- Aprovar fornecedores, documentação fiscal, políticas de troca, qualidade e disponibilidade.
- Definir país(es), moeda(s), transportadoras, frete e prazo de entrega.
- Definir canal oficial de atendimento, privacidade e termos.
- Criar backend dedicado e validar RLS, autenticação, funções de servidor e chaves.
- Integrar gateway e webhooks de pagamento.
- Testar pedido completo em ambiente de teste antes de receber cobranças reais.

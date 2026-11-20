# SensuaMix

Loja online de lingerie plus size e bem-estar íntimo para adultos (18+), com operação sem estoque próprio e atendimento por fornecedores parceiros de pronta entrega.

## Modelo de operação
- A SensuaMix não mantém estoque próprio.
- Pronta entrega depende de confirmação atual do fornecedor.
- Preço, moeda, disponibilidade, frete, prazo e embalagem são confirmados antes de qualquer cobrança.
- Quando contratado e confirmado, o fornecedor despacha diretamente ao consumidor.
- A SensuaMix acompanha o atendimento e o status da expedição.

## Estado desta versão
- Vitrine responsiva com categorias e catálogo ilustrativo.
- Busca e filtros por categoria.
- Lista de interesse local, sem geração de pedido ou cobrança.
- Fluxo explicativo de pronta entrega por parceiro.
- Confirmação de idade 18+.
- Sem login, banco dedicado, painel administrativo, cadastro persistente de fornecedores, checkout, pagamentos, cálculo de frete ou rastreio integrado.
- Nenhum preço ou quantidade de estoque é anunciado como vigente.

## Estrutura de operação e backend
- docs/modelo-operacional.md: fluxo de parceiro, confirmação, aprovação do cliente, pagamento e despacho.
- supabase/schema-draft.sql: proposta de banco para fornecedores, ofertas, produtos, pedidos, pagamentos e expedições com RLS. Não foi aplicada.

## Desenvolvimento
Abra index.html em um navegador. Não requer build step. Busca, filtros, confirmação etária e lista de interesse funcionam no navegador. A lista de interesse pode ser copiada; ela não é enviada a nenhum sistema.

## Segurança e conformidade
- Não colocar service-role/secret keys no frontend.
- Habilitar e validar RLS em todas as tabelas expostas.
- Autorização administrativa via app_metadata, nunca user_metadata.
- Não coletar dados pessoais de compra até o backend e as políticas de privacidade estarem implementados.
- Antes das vendas, validar fornecedores, documentação fiscal, qualidade, regularização dos produtos, entrega, troca/devolução, privacidade, tributação e meios de pagamento no país de operação.

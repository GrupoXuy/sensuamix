# SensuaMix

Loja online de lingerie plus size e bem-estar íntimo para adultos (18+), com operação sem estoque próprio e atendimento por fornecedores parceiros de pronta entrega.

## Modelo de operação
- A SensuaMix não mantém estoque próprio.
- Pronta entrega depende de confirmação atual do fornecedor e validade registrada na oferta.
- Preço, moeda, disponibilidade, frete, prazo e embalagem são confirmados antes de qualquer cobrança.
- Quando contratado e confirmado, o fornecedor despacha diretamente ao consumidor.
- A SensuaMix acompanha o atendimento e o status da expedição.

## Funcionalidades desta versão
- Vitrine responsiva, busca, filtros e confirmação 18+.
- Catálogo público alimentado por produtos publicados no Supabase, preservando a vitrine de demonstração como fallback.
- Cadastro, login, sessão persistente e recuperação de senha por e-mail.
- Área do cliente com dados cadastrais e histórico de seus próprios pedidos.
- Painel administrativo protegido por `app_metadata.role = sensuamix_admin`, com resumo, produtos, fornecedores, ofertas, pedidos e clientes.
- Ofertas vinculadas a fornecedor, com confirmação de disponibilidade e validade de 24 horas.
- Não há estoque próprio, checkout, cobrança nem criação de pedidos pelo cliente nesta fase.

## Supabase
- Projeto: `wkikpqfusgwpbrnrnlfi`.
- Schema com nove tabelas, RLS habilitado e políticas para clientes e administradores.
- O cadastro cria automaticamente o perfil em `customer_profiles` via trigger.
- Autorização administrativa usa exclusivamente `app_metadata`, nunca `user_metadata`.
- Somente URL de projeto e publishable key são entregues ao navegador. Nenhuma chave service-role/secret é usada no frontend.

## Vercel
- Build command: `sh scripts/build.sh`
- Output directory: `public`
- Variáveis necessárias: `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`.
- O script gera `public/runtime-config.js` durante o build, sem gravar segredos no repositório.
- Os assets do módulo e estilos ficam empacotados em gzip em `build/` e são expandidos na etapa de build.

## Primeiro acesso administrativo
1. Criar a conta do administrador em Authentication > Users ou pelo cadastro normal.
2. Atribuir o claim `app_metadata.role = sensuamix_admin` por canal administrativo confiável (Dashboard/Management API).
3. Fazer novo login para atualizar o JWT e liberar o painel.
4. Cadastrar fornecedores aprovados, produtos e ofertas com confirmação atual.

Nenhum usuário ou administrador foi criado automaticamente.

## Operação e segurança
- Não colocar service-role/secret keys no frontend.
- Manter RLS habilitado em todas as tabelas expostas.
- Nenhuma conta pode promover a si mesma a administradora.
- Não coletar dados de cartão nem iniciar cobrança nesta etapa.
- Antes das vendas, validar fornecedores, documentação fiscal, qualidade, regularização dos produtos, entrega, troca/devolução, privacidade, tributação e meios de pagamento no país de operação.

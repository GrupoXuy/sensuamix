# Suh — integração de produção

## Comportamento do site

- A apresentação da Suh é executada uma única vez por sessão do navegador, depois da confirmação de idade.
- O vídeo não possui atributo loop; termina e troca para a imagem frontal estática.
- A chave de sessão sensuamix-suh-intro-played-v1 impede que a introdução reinicie durante a mesma sessão.
- Em rotas administrativas/de conta, em caso de erro de reprodução ou com prefers-reduced-motion: reduce, a imagem final é mostrada diretamente.
- O vídeo usa preload="metadata" para evitar baixar todo o arquivo antes da interação.

## Arquivos de mídia

- public/videos/suh-entrance.mp4: H.264/AVC, 438×390, 12 fps, 3,67 s, 44 quadros.
- public/videos/suh-entrance.webm: VP9, mesma dimensão e duração.
- public/videos/suh-preview.gif: prévia de 438×389, 8 quadros úteis, sem repetição.
- public/images/suh-final.png: pose frontal usada como poster e imagem permanente após o vídeo.

O build baixa o pacote de mídia de um endereço permanente, verifica o SHA-256 e extrai somente os quatro arquivos autorizados. O restante da aplicação e os módulos do painel não são sobrescritos.

## Limitação visual da fonte

A fonte tem 8 poses úteis a 438×389 px. Ela mostra a transição de costas para frente e termina com o celular em uma mão e a outra na cintura. Não contém um gesto completo de chamar o visitante com os dedos nem um giro corporal contínuo entre poses. O vídeo atual não deve ser descrito como contendo esses movimentos. A imagem e a resolução também não são 1080×1920 / 9:16.

## Validação

O build valida os módulos administrativos e de clientes, o shell script e a paridade dos documentos de entrada das rotas públicas, administrativas e de conta. A revisão não altera pedidos, pagamentos, caixa, autenticação ou políticas do banco.

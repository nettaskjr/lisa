# Lisa
Lisa é um sistema de backup que utiliza o rsync como principal forma de backup e sincronismo 'Origem/Destino'.

Criada especialmente para fazer backups 'localmente' em dispositivos removiveis ou não, Pendrives, HD, HD Externo.
A Lisa não utiliza os nomes de dispositivos, exemplo (/dev/sdb) (/dev/sdc) ao invés disto é utilizado o UUID do dispositivo.
Com a informação do UUID do dispositivo fica menos sucessivel a falhas. Existem vários problemas relacionados principalmente com HD's Externo, as vezes montamos como /dev/sdb por exemplo, e ao desmontar é trocado para /dev/sdc, com isto é gerado uma falha no backup, prefira indiciar o UUID.
O UUID do hd será gravado na primeira execução do script caso queira alterar o UUID, apague o arquivo hd que está na raiz, e execute novamente o script, ou altere a informação neste mesmo arquivo.
Ao iniciar o script, caso seja a primeira vez, será solicitado o UID do dispositivo a ser utilizado.
Será informado as partiçoes montadas, para facilitar a localização do UID.

## Mudanças recentes (melhorias)
- Verificações mais robustas: `command -v rsync`, `set -euo pipefail`.
- Correções de quoting de variáveis para evitar word splitting.
- Bloco de montagem corrigido (sem quebras por barras invertidas), uso de `grep -F` e `mkdir -p`.
- Criação automática do diretório de log (`/var/log/lisa.log`).
- Correção do nome da variável de ambiente `LINKSYMBOLS` (antes `LINKSYMVOLS`).
- Excludes do rsync corrigidos (sem aspas internas que quebravam o shell).

## Requisitos
- Linux com Bash.
- Permissões de superusuário (root) para montar dispositivos e escrever em `/var/log`.
- `rsync` instalado.

## Instalação e configuração
1. Copie o script `lisa` para um diretório de sua preferência.
2. Torne-o executável:
   ```bash
   chmod +x ./lisa
   ```
3. Na primeira execução, o script listará os dispositivos montados com UUID e pedirá que você escolha um número. Ele criará o arquivo `hd` ao lado do script com o conteúdo `UUID=<uuid-selecionado>`.
   - Alternativamente, você pode criar/editar manualmente o arquivo `hd` antes de executar.

## Uso
Execute como root:
```bash
sudo ./lisa
```

Por padrão, o script:
- Faz backup de `diretorio_para_envio="/home/"` para o dispositivo com o `UUID` configurado.
- Monta o dispositivo em `/mnt/bck` caso ainda não esteja montado.
- Escreve logs em `/var/log/lisa.log` (criando o diretório, se necessário).

Durante a primeira execução interativa, você verá algo como:
```
Dispositivos com UUID detectados (inclui não montados; exclui FSTYPE ntfs/vfat/swap):
[1] NAME=sdb1 LABEL=Backup UUID=xxxx-yyyy MOUNTPOINT=/media/disk FSTYPE=vfat
[2] NAME=sdc1 LABEL=- UUID=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee MOUNTPOINT=/mnt/data FSTYPE=ext4

Digite o número do dispositivo para gravação do backup:
```
Após escolher o número, o script exibirá uma confirmação com o LABEL e o UUID:
```
Você selecionou: LABEL='Backup' UUID='xxxx-yyyy'
Confirmar cadastro deste dispositivo? (s/N):
```
Responda `s` para confirmar. Caso contrário, a operação é cancelada e nada é salvo.

## Opções via variáveis de ambiente
As seguintes variáveis podem ser definidas para ativar/desativar opções do `rsync`. Valor padrão entre parênteses.

- `VERBOSE` (sim): habilita `--verbose`.
- `QUIET` (nao): habilita `--quiet` (exclusivo com VERBOSE).
- `UPDATE` (sim): habilita `--update`.
- `DELETE` (sim): habilita `--delete` (exclusivo com UPDATE).
- `HUMAN` (sim): habilita `--human-readable`.
- `ARCHIVE` (sim): habilita `--archive`.
- `RECURSIVE` (nao): habilita `--recursive`.
- `COMPRESS` (sim): habilita `--compress`.
- `PROGRESS` (sim): habilita `--progress`.
- `LINKSYMBOLS` (nao): habilita `--safe-links`.
- `PERMS` (sim): habilita `--perms`.

Exemplos:
```bash
sudo VERBOSE=nao QUIET=sim DELETE=nao UPDATE=sim ./lisa
sudo PROGRESS=nao COMPRESS=nao ./lisa
```

Conflitos tratados automaticamente:
- Se `DELETE`=sim, `UPDATE` é desativado.
- Se `VERBOSE`=sim, `QUIET` é desativado (e vice-versa).

## Excludes padrão
Os seguintes caminhos em `/home/` são excluídos por padrão:
- `nestor/.cache/`
- `nestor/s3/`
- `nestor/VirtualBox VMs/`
- `nestor/Insync/`
- `nestor/.config/Insync/`
- `nestor/.local/share/Insync/`
- `nestor/.var/app/com.valvesoftware.Steam/Insync/`
- `nestor/AppImages/`
- `nestor/Projetos-github/`
- `timeshift/`

Edite as variáveis `exclude1..exclude10` no script para ajustar às suas necessidades.

## Logs
- Arquivo: `/var/log/lisa.log`.
- Itens registrados: horário de início/fim, dispositivo, ponto de montagem, diretório de origem, tamanho do backup, uso do disco.

## Montagem do dispositivo
- O dispositivo é resolvido por `UUID` e montado automaticamente em `/mnt/bck` se necessário.
- Você pode montar manualmente em outro diretório; o script detecta e usa o ponto atual.

## Restauração
Para restaurar, utilize o `rsync` no sentido inverso:
```bash
rsync -avh [origem] [destino]
```

## Uso em cron (não interativo)
Para evitar prompts na primeira execução, crie previamente o arquivo `hd` ao lado do script com o conteúdo correto de `UUID`.
Exemplo de entrada no crontab (executa diariamente às 02:00):
```bash
0 2 * * * root VERBOSE=nao QUIET=sim /caminho/para/lisa >> /var/log/lisa.log 2>&1
```

## Observações
- Execute sempre como `root` para permitir montagem e escrita de logs.
- Ajuste `diretorio_para_envio` no script caso deseje outro diretório de origem.
- Em ambientes com muitos arquivos, considere opções adicionais do rsync como `--delete-delay`, `--numeric-ids` e `--info=progress2` (edite no script conforme necessidade).

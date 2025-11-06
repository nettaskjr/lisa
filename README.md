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

### Método 1: Instalador Automático (Recomendado)

1. Baixe o instalador:
   ```bash
   wget https://raw.githubusercontent.com/seu-usuario/lisa/main/install.sh
   chmod +x install.sh
   ```

2. Execute o instalador:
   ```bash
   sudo ./install.sh
   ```

3. O Lisa será instalado em `/usr/local/bin/lisa` e poderá ser executado de qualquer lugar:
   ```bash
   sudo lisa
   ```

### Método 2: Instalação Manual

1. Copie o script `lisa` para um diretório de sua preferência.
2. Torne-o executável:
   ```bash
   chmod +x ./lisa
   ```
3. Na primeira execução, o script listará os dispositivos montados com UUID e pedirá que você escolha um número. Ele criará o arquivo `hd` ao lado do script com o conteúdo `UUID=<uuid-selecionado>`.
   - Alternativamente, você pode criar/editar manualmente o arquivo `hd` antes de executar.

### Método 3: Via Makefile

```bash
# Verificar dependências
make check

# Instalar
sudo make install

# Desinstalar
sudo make uninstall

# Executar testes
make test

# Criar pacote de distribuição
make build
```

### Método 4: Via Release do GitHub

1. Acesse a [página de releases](https://github.com/seu-usuario/lisa/releases)
2. Baixe o arquivo `lisa-X.X.tar.gz` da versão desejada
3. Extraia e instale:
   ```bash
   tar -xzf lisa-X.X.tar.gz
   sudo ./install.sh
   ```

### Verificação de Integridade

Ao baixar releases, verifique o checksum:
```bash
sha256sum -c lisa-X.X.tar.gz.sha256
```

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
Os excludes são configurados através do arquivo `excludes` (no diretório do script ou em `/etc/lisa/excludes` quando instalado).

O arquivo `excludes` contém um padrão por linha. Linhas começando com `#` são comentários e serão ignoradas.

Exemplo de conteúdo do arquivo `excludes`:
```
nestor/.cache/
nestor/s3/
nestor/VirtualBox VMs/
nestor/Insync/
nestor/.config/Insync/
nestor/.local/share/Insync/
nestor/.var/app/com.valvesoftware.Steam/Insync/
nestor/AppImages/
nestor/Projetos-github/
timeshift/
```

**Localização do arquivo:**
- Se instalado: `/etc/lisa/excludes` (prioridade)
- Se não instalado: `excludes` no mesmo diretório do script

Edite o arquivo `excludes` para ajustar os padrões de exclusão conforme suas necessidades.

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
Para evitar prompts na primeira execução, crie previamente:
- O arquivo `hd` (ou `/etc/lisa/hd`) com o conteúdo `UUID=<seu-uuid>`
- O arquivo `excludes` (ou `/etc/lisa/excludes`) com os padrões de exclusão desejados

Exemplo de entrada no crontab (executa diariamente às 02:00):
```bash
0 2 * * * root VERBOSE=nao QUIET=sim /usr/local/bin/lisa >> /var/log/lisa.log 2>&1
```

## CI/CD

O projeto utiliza GitHub Actions para automação de CI/CD com as seguintes funcionalidades:

- **Lint e Validação**: Verificação de sintaxe Bash e análise estática com ShellCheck
- **Testes**: Validação de estrutura e dependências do script
- **Build Automático**: Criação de pacotes de distribuição (.tar.gz) com checksums
- **Release Automático**: Criação automática de releases ao criar tags `v*`

### Workflow

O workflow é acionado em:
- Push para branches `main` e `develop`
- Pull requests para `main` e `develop`
- Criação de tags `v*` (gera release automático)
- Execução manual via `workflow_dispatch`

### Jobs do CI/CD

1. **lint**: Valida sintaxe, shebang e permissões
2. **test**: Testa estrutura e funções críticas
3. **build**: Cria pacote de distribuição e artifacts
4. **release**: Cria release no GitHub com downloads

## Desenvolvimento

### Pré-requisitos para Desenvolvimento

```bash
# Instalar ferramentas de desenvolvimento
sudo apt-get install -y shellcheck make

# Ou em outras distribuições:
sudo yum install -y ShellCheck make        # RHEL/CentOS
sudo dnf install -y ShellCheck make        # Fedora
sudo pacman -S shellcheck make             # Arch
```

### Comandos Úteis

```bash
# Executar linting
make lint

# Executar testes
make test

# Verificar dependências
make check

# Criar build local
make build

# Limpar arquivos de build
make clean
```

## Observações
- Execute sempre como `root` para permitir montagem e escrita de logs.
- Ajuste `diretorio_para_envio` no script caso deseje outro diretório de origem.
- Em ambientes com muitos arquivos, considere opções adicionais do rsync como `--delete-delay`, `--numeric-ids` e `--info=progress2` (edite no script conforme necessidade).
- O arquivo de configuração `hd` é criado automaticamente na primeira execução ou pode ser editado manualmente.
- O arquivo `excludes` pode ser criado manualmente para personalizar os padrões de exclusão do rsync.

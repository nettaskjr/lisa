# GitHub Actions Workflows

Este diretório contém os workflows de CI/CD do projeto Lisa.

## Workflow Principal: `ci.yml`

### Funcionalidades

1. **Lint e Validação** (`lint` job)
   - Verifica sintaxe Bash com `bash -n`
   - Executa análise estática com ShellCheck
   - Valida shebang e permissões

2. **Testes** (`test` job)
   - Valida estrutura do script
   - Verifica presença de funções críticas
   - Testa dependências

3. **Build** (`build` job)
   - Cria pacote de distribuição (.tar.gz)
   - Gera checksum SHA256
   - Cria artifacts para download

4. **Release** (`release` job)
   - Cria release automático ao criar tag `v*`
   - Anexa arquivos de build
   - Gera notas de release

### Triggers

- Push para `main` e `develop`
- Pull requests para `main` e `develop`
- Criação de tags `v*` (ex: `v1.2.0`)
- Execução manual via GitHub Actions UI

### Como Criar uma Release

1. Atualize a versão no script `lisa` (cabeçalho)
2. Commit e push:
   ```bash
   git add lisa
   git commit -m "Bump version to 1.3"
   git push
   ```
3. Crie uma tag:
   ```bash
   git tag -a v1.3 -m "Release version 1.3"
   git push origin v1.3
   ```
4. O workflow criará automaticamente a release no GitHub

### Artifacts

Os artifacts são mantidos por 30 dias e incluem:
- `lisa-X.X.tar.gz` - Pacote de distribuição
- `lisa-X.X.tar.gz.sha256` - Checksum SHA256
- `VERSION` - Arquivo com versão e commit SHA


.PHONY: help install uninstall test lint clean build release check

# Variáveis
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
CONFDIR ?= /etc/lisa
VERSION ?= 1.2
SCRIPT_NAME = lisa

help: ## Mostra esta mensagem de ajuda
	@echo "Lisa - Sistema de Backup"
	@echo ""
	@echo "Targets disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Instala o Lisa no sistema
	@echo "Instalando Lisa..."
	@sudo mkdir -p $(BINDIR)
	@sudo cp $(SCRIPT_NAME) $(BINDIR)/$(SCRIPT_NAME)
	@sudo chmod +x $(BINDIR)/$(SCRIPT_NAME)
	@sudo mkdir -p $(CONFDIR)
	@if [ -f hd ]; then \
		sudo cp hd $(CONFDIR)/hd; \
		sudo chmod 600 $(CONFDIR)/hd; \
	fi
	@if [ -f excludes ]; then \
		sudo cp excludes $(CONFDIR)/excludes; \
		sudo chmod 644 $(CONFDIR)/excludes; \
	fi
	@echo "Lisa instalado em $(BINDIR)/$(SCRIPT_NAME)"
	@echo "Execute: sudo $(SCRIPT_NAME)"

uninstall: ## Remove o Lisa do sistema
	@echo "Desinstalando Lisa..."
	@sudo rm -f $(BINDIR)/$(SCRIPT_NAME)
	@sudo rm -f $(BINDIR)/lisa-backup
	@echo "Lisa removido"

test: ## Executa testes básicos
	@echo "Executando testes..."
	@bash -n $(SCRIPT_NAME) || (echo "Erro de sintaxe!" && exit 1)
	@echo "✓ Sintaxe válida"
	@command -v shellcheck >/dev/null 2>&1 && shellcheck $(SCRIPT_NAME) || echo "ShellCheck não instalado, pulando..."
	@echo "✓ Testes concluídos"

lint: ## Executa linting no código
	@echo "Executando linting..."
	@command -v shellcheck >/dev/null 2>&1 || (echo "Instale shellcheck: sudo apt-get install shellcheck" && exit 1)
	@shellcheck -x $(SCRIPT_NAME)
	@echo "✓ Linting concluído"

check: ## Verifica dependências e instalação
	@echo "Verificando dependências..."
	@command -v rsync >/dev/null 2>&1 || (echo "✗ rsync não encontrado" && exit 1)
	@command -v blkid >/dev/null 2>&1 || (echo "✗ blkid não encontrado (instale util-linux)" && exit 1)
	@command -v lsblk >/dev/null 2>&1 || (echo "✗ lsblk não encontrado (instale util-linux)" && exit 1)
	@echo "✓ Todas as dependências estão instaladas"
	@if [ -f $(BINDIR)/$(SCRIPT_NAME) ]; then \
		echo "✓ Lisa está instalado em $(BINDIR)/$(SCRIPT_NAME)"; \
	else \
		echo "✗ Lisa não está instalado"; \
	fi

build: ## Cria pacote de distribuição
	@echo "Criando pacote..."
	@mkdir -p dist
	@cp $(SCRIPT_NAME) dist/
	@cp README.md dist/
	@echo "$(VERSION)" > dist/VERSION
	@cd dist && tar -czf lisa-$(VERSION).tar.gz $(SCRIPT_NAME) README.md VERSION
	@cd dist && sha256sum lisa-$(VERSION).tar.gz > lisa-$(VERSION).tar.gz.sha256
	@echo "✓ Pacote criado em dist/lisa-$(VERSION).tar.gz"

clean: ## Remove arquivos de build
	@echo "Limpando arquivos de build..."
	@rm -rf dist/
	@echo "✓ Limpeza concluída"

release: build ## Cria release (build + checksum)
	@echo "Release $(VERSION) criado em dist/"
	@ls -lh dist/

.DEFAULT_GOAL := help


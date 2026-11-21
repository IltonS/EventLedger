# EventLedger — Aplicativo Desktop em Flutter (pt-BR)

Aplicativo desktop escrito em Dart e Flutter para gerenciar despesas de eventos pessoais, como festas de aniversário, jantares comemorativos e reuniões em família, totalmente localizado para **português do Brasil (`pt_BR`)** com formatação em Reais (`R$`) e datas brasileiras.

## Funcionalidades
- **Painel de Despesas Totais**: Totais consolidados de todos os eventos (Total Gasto, Total Pago, Saldo a Pagar, Orçamentos Combinados), gráfico de gastos por categoria e tabela resumo de eventos.
- **Gestão de Eventos Pessoais**: Crie, edite e exclua eventos com data, local e orçamento previsto.
- **Lançamento e Categorização de Despesas**: Registre despesas por evento com fornecedor, valor em `R$`, data e categoria (`Espaço / Local`, `Buffet e Bebidas`, `Decoração`, `Entretenimento`, `Lembrancinhas`, `Fotografia`, `Convites`, `Outros`).
- **Controle de Pagamento (Pago / Pendente)**: Alterne com um clique entre pago e pendente com recálculo imediato dos saldos.
- **Persistência Local no Desktop**: Salva e carrega eventos e despesas em JSON no diretório de suporte do aplicativo.

* **Linux**
```
~/.local/share/com.github.iltons.EventLedger/event_ledger_data.json
```

* **macOS**
```
~/Library/Application Support/ccom.github.iltons.EventLedger/event_ledger_data.json
```

* **Windows**
```
%APPDATA%\com.github.iltons.EventLedger\event_ledger_data.json
```

## Como Executar no Desktop (Windows, macOS, Linux)

1. Certifique-se de ter o Flutter (`>=3.22`) instalado com suporte desktop habilitado:
   ```bash
   flutter config --enable-macos-desktop
   flutter config --enable-windows-desktop
   flutter config --enable-linux-desktop
   ```
2. Gere os arquivos de plataforma desktop nesta pasta, se ainda não existirem:
   ```bash
   cd flutter_desktop_app
   flutter create --platforms=windows,macos,linux .
   ```
3. Instale as dependências e execute:
   ```bash
   flutter pub get
   flutter run -d macos   # ou -d windows / -d linux
   ```

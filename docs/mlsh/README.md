# 🧩 ml-debug — Modular Debug Environment

`ml-debug` è un sistema modulare di diagnostica e debug, scritto in **Bash puro**, con interfaccia minimale basata su **rofi**.  
È pensato per fornire un accesso rapido e organizzato a script di debug distribuiti nei vari moduli della tua dotfile repository.

---

## 🚀 Funzionalità principali

- **Interfaccia grafica minimale** via `rofi`, con markup Pango (bold + italic)
- **Navigazione a due livelli**:
  - menu dei moduli (`[general]`, `[flatpak]`, ecc.)
  - menu dei tool con descrizione e opzione `[BACK]`
- **Esecuzione asincrona**: ogni tool viene eseguito in background con log dedicato
- **File `config.json`** generato automaticamente via `--init`
- **Supporto descrizioni (`@about`)** direttamente nel codice degli script
- **Struttura modulare**: ogni modulo della repo `.dotfiles` contribuisce i propri tool

---

## 🧱 Struttura del progetto

``` plaintext
~/.dotfiles/
├── mlsh/.local/share/mlsh/ → modulo [general]
│ ├── ml-video.sh
│ ├── ml-network.sh
│ └── ...
├── flatpak/.local/share/mlsh/ → modulo [flatpak]
│ ├── ml-flatpak1.sh
│ └── ...
└── othermodule/.local/share/mlsh/ → modulo [othermodule]
└── ml-example.sh

~/.local/
├── bin/ml-debug → entry point principale
└── share/mlsh/
├── ml-menu.sh → gestisce i menu rofi
├── ml-utils.sh → logging, notifiche, helpers
└── (eventuali tool generali)

~/.config/ml-debug/config.json → configurazione generata da --init
~/.local/share/ml-debug/logs/ → log per ogni tool
```


---

## 🧩 Installazione e setup

1. Copia i file negli stessi percorsi sopra indicati.
2. Rendi eseguibili i file principali:
   ```bash
   chmod +x ~/.local/bin/ml-debug ~/.local/share/mlsh/*.sh

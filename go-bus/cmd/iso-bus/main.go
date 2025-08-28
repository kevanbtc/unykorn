package main

import (
    "encoding/json"
    "flag"
    "fmt"
    "log"
    "net/http"
    "os"
    "path/filepath"
    "time"

    "gopkg.in/yaml.v3"
)

type Config struct {
    HTTP struct {
        Addr string `yaml:"addr" json:"addr"`
    } `yaml:"http" json:"http"`
    DataDir  string `yaml:"data_dir" json:"data_dir"`
    LogLevel string `yaml:"log_level" json:"log_level"`
    Institution struct {
        Name string `yaml:"name" json:"name"`
        BIC  string `yaml:"bic" json:"bic"`
        LEI  string `yaml:"lei" json:"lei"`
    } `yaml:"institution" json:"institution"`
}

var cfg Config

func main() {
    var cfgPath string
    var dataOverride string
    flag.StringVar(&cfgPath, "config", "./config/config.yaml", "config file path")
    flag.StringVar(&dataOverride, "data", "", "data dir override")
    flag.Parse()

    b, err := os.ReadFile(cfgPath)
    if err != nil {
        log.Fatalf("read config: %v", err)
    }
    if err := yaml.Unmarshal(b, &cfg); err != nil {
        if err2 := json.Unmarshal(b, &cfg); err2 != nil {
            log.Fatalf("parse config: yaml=%v json=%v", err, err2)
        }
    }

    if dataOverride != "" {
        cfg.DataDir = dataOverride
    }
    if cfg.DataDir == "" {
        cfg.DataDir = ".iso-bus-data"
    }
    if err := os.MkdirAll(cfg.DataDir, 0o755); err != nil {
        log.Fatalf("mkdir data: %v", err)
    }

    http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        _, _ = w.Write([]byte("ok"))
    })

    http.HandleFunc("/iso/pacs008", handlePacs008)
    http.HandleFunc("/callbacks/hold", handleHoldCallback)

    addr := cfg.HTTP.Addr
    if addr == "" {
        addr = ":8080"
    }
    log.Printf("ISO-bus listening on %s (data=%s)", addr, cfg.DataDir)
    log.Fatal(http.ListenAndServe(addr, nil))
}

type ChainTransfer struct {
    TxHash      string `json:"tx_hash"`
    FromAcct    string `json:"from_account"`
    ToAcct      string `json:"to_account"`
    Currency    string `json:"currency"`
    Amount      string `json:"amount"`
    Reference   string `json:"reference"`
    OccurredAt  string `json:"occurred_at"`
    Beneficiary string `json:"beneficiary_name"`
    Originator  string `json:"originator_name"`
}

type PACS008 struct {
    MessageID    string `json:"message_id"`
    CreationDT   string `json:"creation_dt"`
    InstName     string `json:"inst_name"`
    InstBIC      string `json:"inst_bic"`
    InstLEI      string `json:"inst_lei"`
    TxRef        string `json:"tx_reference"`
    Currency     string `json:"currency"`
    Amount       string `json:"amount"`
    DebtorName   string `json:"debtor_name"`
    CreditorName string `json:"creditor_name"`
    DebtorAcct   string `json:"debtor_account"`
    CreditorAcct string `json:"creditor_account"`
}

func handlePacs008(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
        return
    }
    var evt ChainTransfer
    if err := json.NewDecoder(r.Body).Decode(&evt); err != nil {
        http.Error(w, fmt.Sprintf("bad json: %v", err), http.StatusBadRequest)
        return
    }
    msg := PACS008{
        MessageID:    "MSG-" + time.Now().UTC().Format("20060102T150405.000Z07:00"),
        CreationDT:   time.Now().UTC().Format(time.RFC3339Nano),
        InstName:     cfg.Institution.Name,
        InstBIC:      cfg.Institution.BIC,
        InstLEI:      cfg.Institution.LEI,
        TxRef:        evt.Reference,
        Currency:     evt.Currency,
        Amount:       evt.Amount,
        DebtorName:   evt.Originator,
        CreditorName: evt.Beneficiary,
        DebtorAcct:   evt.FromAcct,
        CreditorAcct: evt.ToAcct,
    }
    b, _ := json.MarshalIndent(msg, "", "  ")
    fn := filepath.Join(cfg.DataDir, fmt.Sprintf("pacs008_%d.json", time.Now().UnixNano()))
    _ = os.WriteFile(fn, b, 0o644)
    w.Header().Set("Content-Type", "application/json")
    _, _ = w.Write(b)
}

type HoldCallback struct {
    HoldID string `json:"hold_id"`
    Status string `json:"status"`
}

func handleHoldCallback(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
        return
    }
    var cb HoldCallback
    if err := json.NewDecoder(r.Body).Decode(&cb); err != nil {
        http.Error(w, "bad json", http.StatusBadRequest)
        return
    }
    b, _ := json.MarshalIndent(cb, "", "  ")
    fn := filepath.Join(cfg.DataDir, fmt.Sprintf("holdcb_%d.json", time.Now().UnixNano()))
    _ = os.WriteFile(fn, b, 0o644)
    w.WriteHeader(http.StatusOK)
    _, _ = w.Write([]byte("ok"))
}

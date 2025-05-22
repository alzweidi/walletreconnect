#!/bin/bash

# === CONFIG ===
NEW_PUBKEY="3HSoV75HMUdwyrL7FkGA3rx2nVaTeVKmvPzewxhR2qeVPmYg85Y7YxfHgHofMoHQk38voxz55U84YhQmewucKxjVswTMgdfEnD3GX4PXdDxouhQYKgTEL3rsDdjKoztbiEUT"
PROJECT_DIR="$HOME/nockchain"
MAKEFILE="$PROJECT_DIR/Makefile"
ENVFILE="$PROJECT_DIR/.env"
MINER_BIN="$PROJECT_DIR/target/release/nockchain"

echo "🔧 Killing old miner (tmux and process)..."
tmux kill-session -t nock-miner 2>/dev/null || pkill -f nockchain

echo "🧹 Cleaning up socket files..."
rm -rf "$PROJECT_DIR/.socket"

echo "🛠 Updating Makefile..."
if grep -q '^PUBKEY :=' "$MAKEFILE"; then
  sed -i "s/^PUBKEY := .*/PUBKEY := $NEW_PUBKEY/" "$MAKEFILE"
else
  echo "PUBKEY := $NEW_PUBKEY" >> "$MAKEFILE"
fi

echo "🛠 Updating .env file..."
if [ -f "$ENVFILE" ]; then
  if grep -q '^PUBKEY=' "$ENVFILE"; then
    sed -i "s/^PUBKEY=.*/PUBKEY=$NEW_PUBKEY/" "$ENVFILE"
  else
    echo "PUBKEY=$NEW_PUBKEY" >> "$ENVFILE"
  fi
else
  echo "PUBKEY=$NEW_PUBKEY" > "$ENVFILE"
fi

echo "🚀 Starting miner in new tmux session..."
cd "$PROJECT_DIR"
tmux new-session -d -s nock-miner "$MINER_BIN --mining-pubkey $NEW_PUBKEY --mine"

echo "✅ Miner running inside tmux session: nock-miner"
echo "Use: tmux attach -t nock-miner"

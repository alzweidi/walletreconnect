#!/bin/bash

# === CONFIG ===
NEW_PUBKEY="3HSoV75HMUdwyrL7FkGA3rx2nVaTeVKmvPzewxhR2qeVPmYg85Y7YxfHgHofMoHQk38voxz55U84YhQmewucKxjVswTMgdfEnD3GX4PXdDxouhQYKgTEL3rsDdjKoztbiEUT"
PROJECT_DIR="$HOME/nockchain"
MAKEFILE="$PROJECT_DIR/Makefile"
ENVFILE="$PROJECT_DIR/.env"
LOGFILE="$PROJECT_DIR/miner.log"

echo "🔧 Killing old miner..."
pkill -f nockchain || echo "No miner process found."

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

echo "🛠 Rebuilding miner (optional)..."
cd "$PROJECT_DIR"
make miner

echo "🚀 Starting miner with new pubkey..."
nohup ./target/release/nockchain --mining-pubkey "$NEW_PUBKEY" --mine > "$LOGFILE" 2>&1 &

echo "✅ Miner restarted using: nockchain --mining-pubkey $NEW_PUBKEY --mine"

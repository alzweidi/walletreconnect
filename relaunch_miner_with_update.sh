#!/bin/bash

# === CONFIG ===
PROJECT_DIR="$HOME/nockchain"
SOCKET_DIR="$PROJECT_DIR/.socket"
MINER_SCRIPT="$PROJECT_DIR/scripts/run_nockchain_miner.sh"

cd "$PROJECT_DIR" || { echo "❌ Failed to cd into $PROJECT_DIR"; exit 1; }

echo "🔧 Killing old tmux miner session if it exists..."
if tmux has-session -t nock-miner 2>/dev/null; then
  tmux kill-session -t nock-miner
  echo "✅ tmux session 'nock-miner' killed."
else
  echo "⚠️ tmux session 'nock-miner' not found."
fi

echo "🧹 Cleaning up socket files..."
rm -rf "$SOCKET_DIR"
echo "✅ Removed $SOCKET_DIR"

echo "📥 Pulling latest repo changes..."
git reset --hard HEAD && git pull
echo "✅ Repo updated."

echo "🚀 Starting miner using: $MINER_SCRIPT"
tmux new-session -d -s nock-miner "sh $MINER_SCRIPT"

sleep 1
if tmux has-session -t nock-miner 2>/dev/null; then
  echo "✅ Miner is now running inside tmux (session: nock-miner)"
  echo "   Attach with: tmux attach -t nock-miner"
else
  echo "❌ Miner failed to start inside tmux."
fi

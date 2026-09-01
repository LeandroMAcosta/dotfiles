#!/usr/bin/env bash
set -euo pipefail

echo "==> Applying macOS defaults..."

# --- Finder ---
# Show the full POSIX path in the title bar (/Users/x/dev, not just "dev")
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Hide file extensions (keeps .app etc. hidden in Finder and Spotlight)
defaults write NSGlobalDomain AppleShowAllExtensions -bool false
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show path bar at the bottom
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Don't create .DS_Store on network and USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# --- Keyboard ---
# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
# Short delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable auto-capitalize
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable smart quotes and dashes (annoying in code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# --- Dock ---
# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true
# Remove auto-hide delay
defaults write com.apple.dock autohide-delay -float 0
# Speed up hide/show animation
defaults write com.apple.dock autohide-time-modifier -float 0.3
# Minimize windows to their application icon
defaults write com.apple.dock minimize-to-application -bool true
# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false
# Don't rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# --- Screenshots ---
# Save screenshots to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
# Save as PNG
defaults write com.apple.screencapture type -string "png"
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# --- Trackpad ---
# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- iTerm2 ---
# Set Left + Right Option to Esc+ (required for tmux Alt+letter bindings,
# otherwise dead-keys on Spanish/Latin layouts swallow Option+N etc.).
# Also pin the font to MesloLGS Nerd Font (Powerlevel10k + Catppuccin icons).
# Uses defaults import (cfprefsd-safe) instead of editing the plist directly.
if [[ -f "$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]] && command -v python3 &>/dev/null; then
  defaults export com.googlecode.iterm2 - | python3 -c '
import sys, plistlib
data = plistlib.loads(sys.stdin.buffer.read())
for p in data.get("New Bookmarks", []):
    p["Option Key Sends"] = 2
    p["Right Option Key Sends"] = 2
    p["Normal Font"] = "MesloLGSNFM-Regular 13"
    p["Non Ascii Font"] = "MesloLGSNFM-Regular 13"
sys.stdout.buffer.write(plistlib.dumps(data))
' | defaults import com.googlecode.iterm2 -
  echo "  iTerm2: Option=Esc+, font=MesloLGS NF (restart iTerm to apply)"

  # One profile per terminal mode. The profile picks the multiplexer, not
  # .zshrc, so a plain shell stays plain and tmux/herdr pane shells never
  # re-exec a multiplexer:
  #   Default — plain login shell (stays iTerm's default profile)
  #   tmux    — attaches to the shared "main" session
  #   herdr   — launches the herdr terminal workspace manager
  # Binaries are resolved here so this works on both ARM and Intel Homebrew.
  # Idempotent: missing profiles are created, existing ones have their command
  # refreshed. A profile whose binary is absent is skipped, not created empty.
  defaults export com.googlecode.iterm2 - \
    | TMUX_BIN="$(command -v tmux || true)" HERDR_BIN="$(command -v herdr || true)" python3 -c '
import sys, plistlib, copy, os, uuid

wanted = {}
if os.environ.get("TMUX_BIN"):
    wanted["tmux"] = os.environ["TMUX_BIN"] + " new-session -A -s main"
if os.environ.get("HERDR_BIN"):
    wanted["herdr"] = os.environ["HERDR_BIN"]

data = plistlib.loads(sys.stdin.buffer.read())
profiles = data.get("New Bookmarks", [])
if profiles:
    default_guid = data.get("Default Bookmark Guid")
    base = next((p for p in profiles if p.get("Guid") == default_guid), profiles[0])
    if base.get("Name") not in wanted:
        base["Custom Command"] = "No"
        base["Command"] = ""
    by_name = {p.get("Name"): p for p in profiles}
    for name, command in wanted.items():
        profile = by_name.get(name)
        if profile is None:
            profile = copy.deepcopy(base)
            profile["Name"] = name
            profile["Guid"] = str(uuid.uuid4()).upper()
            profiles.append(profile)
        profile["Custom Command"] = "Yes"
        profile["Command"] = command
    data["New Bookmarks"] = profiles
sys.stdout.buffer.write(plistlib.dumps(data))
' | defaults import com.googlecode.iterm2 -
  echo "  iTerm2: Default/tmux/herdr profiles synced (restart iTerm to apply)"
fi

# --- Restart affected apps ---
echo "==> Restarting affected apps..."
for app in Finder Dock SystemUIServer; do
  killall "$app" &>/dev/null || true
done

echo "Done! Some changes may require logout or restart."

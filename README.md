# Elegant Xiangqi - Claude Code Package

Portrait-mode traditional elegant Chinese Chess for Android + Web.

## Contents
- MUSE.md - Read by Claude Code on startup (project context)
- claude_code_development_plan.md - 5 phases with copy-paste prompts
- docs/elegant_xiangqi_design_doc.md - Full art + AI + campaign design (Imperial Silk & Jade)
- docs/portrait_mode_design.md - Exact portrait layout spec (6%+4%+62%+4%+8%+10%+6%)
- docs/xiangqi_new_themes_research.md - Market research + 4 novel themes
- assets/board/ - Reference images for board and UI

## Quick Start with Claude Code
```bash
npm install -g @anthropic-ai/claude-code
claude login

# Create Flutter project
flutter create --platforms=android,web elegant-xiangqi
cd elegant-xiangqi

# Copy these files to project root
cp -r /path/to/claude_code_package/* .

# Start Claude Code
claude
# Paste Prompt 1 from claude_code_development_plan.md
```

## Portrait Layout
Board 9x10 = naturally portrait. See portrait_mode_design.md for exact measurements.

## Art Direction
- Huanghuali wood #8B5A2B
- Jade white #F5F1E8
- Obsidian black #1A1A1A
- Gold #D4AF37
- Imperial Red #9B1B30
- Celadon #A8C3B9

See elegant_xiangqi_board.jpg for target look.

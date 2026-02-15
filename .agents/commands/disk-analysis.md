---
description: Analyze disk storage and identify cleanup opportunities without affecting system functionality.
---

Perform a comprehensive disk storage analysis on this macOS system:

1. **Overall disk status**: Check total, used, and available space
2. **Analyze these locations** and report their sizes:
   - ~/Library/Caches (list top 10 largest subdirectories)
   - ~/Library/Application Support (list top 10 largest)
   - ~/Library/Containers (list top 10 largest)
   - ~/Library/Developer (Xcode, simulators, derived data)
   - ~/Downloads (flag files >100MB)
   - ~/.Trash
   - Dev tools: ~/.npm, ~/.yarn, ~/.cargo, ~/.rustup, ~/.asdf, ~/.docker, ~/.claude
   - ~/Projects node_modules directories

3. **Categorize findings** into:
   - **Safe to clean**: Caches, logs, old downloads, package manager caches
   - **Review first**: Large files, old backups, Docker data
   - **Keep**: App data, active projects, system files

4. **Provide a summary report** with:
   - Table of largest cleanup opportunities
   - Suggested cleanup commands (but don't run them)
   - Total potential space savings

Focus on items that can be safely cleaned without affecting functionality. Present findings in markdown tables for clarity.

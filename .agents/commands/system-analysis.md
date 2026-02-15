---
description: Analyze system performance (CPU, memory, swap) and identify causes of slowness.
---

Perform a comprehensive system performance analysis on this macOS system:

1. **System overview**:
   - Uptime
   - CPU core count
   - Total RAM
   - Load averages

2. **Memory analysis**:
   - Total, used, free memory
   - Swap usage (vm.swapusage)
   - Memory pressure level
   - Compressor statistics

3. **Process analysis**:
   - Top 15 processes by CPU usage
   - Top 15 processes by memory usage
   - Aggregate memory/CPU by application name
   - Count processes per application (especially browsers)
   - Check for stuck or uninterruptible processes

4. **Identify issues**:
   - Memory exhaustion (low free RAM, high swap)
   - CPU bottlenecks (load > core count)
   - Runaway processes (single process using excessive resources)
   - Long uptime (>7 days suggests restart needed)

5. **Provide recommendations**:
   - Specific processes to quit or restart
   - Whether a system restart is needed
   - Quick fixes (kill commands, purge, etc.)
   - Long-term suggestions

Present findings in markdown tables. Flag critical issues prominently. Include specific process names and PIDs for actionable recommendations.

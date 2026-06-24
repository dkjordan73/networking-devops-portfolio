# Go Network Projects

TCP network health checker built in Go, showing progression from a simple single-port check (v1) to a multi-protocol checker with structs, timing, and file output (v2).

---

## netcheck v1 — Single Port Check (`v1/main.go`)

Basic TCP connectivity check against port 80. First working version — establishes the core pattern of dial, check error, report result.

```bash
go run v1/main.go google.com
# ✔ Host google.com is reachable
```

---

## netcheck v2 — Multi-Protocol Checker (`v2/networkcheck.go`)

Full implementation with custom struct, response timing, multi-port scanning, and file output.

### Usage

```bash
go run v2/networkcheck.go <hostname>

# Examples
go run v2/networkcheck.go google.com
go run v2/networkcheck.go 10.0.1.45
```

### Sample Output

```
🔍 Checking google.com across multiple protocols...

✔ HTTP       (port 80   ) - Reachable in 12.3ms
✔ HTTPS      (port 443  ) - Reachable in 11.8ms
✖ SSH        (port 22   ) - Failed: connection refused
✖ FTP        (port 21   ) - Failed: connection refused
✖ SMTP       (port 25   ) - Failed: i/o timeout
✖ MYSQL      (port 3306 ) - Failed: connection refused

💾 Saving results to file...
✔ Results saved to netcheck_google.com.txt
```

### Key Concepts Demonstrated

- Custom struct (`CheckResult`) to group related data
- Slices and range loops
- TCP socket programming with `net.DialTimeout`
- Response time measurement with `time.Since`
- File I/O with `os.Create` and `WriteString`
- `defer` for guaranteed resource cleanup
- Exit codes for CI/CD pipeline integration

### Use Cases

**Deployment verification** — confirm all expected services are up after provisioning a new server before marking it production-ready.

**Security auditing** — identify ports that should not be publicly exposed (databases, FTP, RDP).

**SLA monitoring** — schedule via cron to log uptime and verify vendor availability against contract terms.

**CI/CD integration** — exits with non-zero code on failure, triggering automatic rollback in pipelines.

### Run via Cron (every 5 minutes)

```bash
*/5 * * * * go run /path/to/v2/networkcheck.go api.company.com >> /var/log/health.log
```

### Planned Improvements

- Concurrent port scanning with goroutines
- YAML config for custom port lists
- Slack / PagerDuty alerting on state change
- Prometheus metrics endpoint
- Retry logic with exponential backoff

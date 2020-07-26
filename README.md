# Overview
A Simpe Ping Client for Ruby.

# How to use
※ Need root privileges to run.

```
ping_client = SimplePing::Client.new(src_ip_addr: "192.168.1.100")
ping_client.exec(dest_ip_addr: "192.168.1.101")
```

# Specification

- Number of executions: 1
- Timeout Seconds: 10s
- Does not support retries
- Confirmed the operation with Ruby 2.7.1

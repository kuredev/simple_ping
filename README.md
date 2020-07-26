# Overview
A Simpe Ping(ICMP) Client for Ruby.

# How to use
※ Need root privileges to run.

```ruby
ping_client = SimplePing::Client.new(src_ip_addr: "192.168.1.100")
ping_client.exec(dest_ip_addr: "192.168.1.101")
```

# Specification

- Number of executions: 1
- Timeout Seconds: 10s
- Does not support retries
- Confirmed the operation with Ruby 2.7.1


# What you can do

- Return the success or failure of the ping (ICMP) result with true/false
- Destination is IP address

# What you can not do now

- Addressing by FQDN
- Retry
- Customized transmission data (ID specification, data section specification, etc.)
- Etc., etc

# License
MIT

# DNS over TLS (TCP over TLS)

cli / docker image the runs a local TCP proxy server forwarding over TLS to a remote server

---
## challenger

`challenger` is a cli tool that enables you to start a listener on a specific tcp port forwarding to a remote server over TLS. It was created with the goal of handling DNS over TLS proxying but can actually be used for other use cases.

It can be useful and easy to implement if you run your applications on kubernetes (for example) and you don't want the risk of a Man-in-the-middle / sniffing attack over your DNS traffic. It's easy to run as a daemonset, for example, and handle requests from other containers inside the cluster and forwarding those requests over TLS to the nameserver. No DNS/TCP traffic using this solution would get out of the cluster unencrypted.

### How it works

|Paramter|Description|
|-------------------|----------------------------|
|--local-addr   | Local listener address. Ex: `127.0.0.1` |
|--local-port     | Local listener port Ex: `53` |
|--remote_addr   | Remote server address: `Ex: 1.1.1.1` |
|--remote_port   | Remote server port: `853` |

### Installation

---
##### *cli (executing localy without docker)*

It's a ruby cli, so it's implicit you need ruby installed :)

With that in mind..
Install all gems
```
gem install bundler
bundle install
```

Executing a sample command (you need sudo depending on the port you use):  
`sudo ./challanger dns_over_tls start --local-addr '127.0.0.1' --local-port 53 --remote-addr '1.1.1.1' --remote-port 853`

Also there's a help option that you can use in case of need:  
`./challanger dns_over_tls --help`

---
##### *docker*

It's docker, so once again it's implicit you need docker :D

Also with that in mind...
Build the image
```
docker build -t challanger .
```

Run the cointainer! (bear in mind that "127.0.0.1" as `local-addr` when running the container would only listen to requests from within the container so you probably want to listen to requests from the outside world)  
`docker run -it -p 127.0.0.1:53:53 challanger dns_over_tls start --local-addr '0.0.0.0' --local-port 53 --remote-addr '1.1.1.1' --remote-port 853`

### Validate

Query a domain using your local tcp proxy:  
`dig www.google.com @127.0.0.1 +tcp`

### Todos
 - security concerns:
    - Encrypt certificate
    - Enable custom certificate and key
    - Enable tls listener (not sure why but why not)
 - other improvments:
    - Handle exceptions (If connection is idle, it breaks :/ - DONT STOP QUERYING!)
    - Implement UDP as an option
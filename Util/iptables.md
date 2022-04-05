## iptables Install
```bash
#sudo iptables -t filter -F  
#sudo iptables -t filter -X 
#systemctl restart docker

# Install
#yum install iptables-services -y
#systemctl enable iptables
#systemctl start iptables

# Port Open
# Opening port TCP/6443 using iptableslink
# Open TCP/6443 for all
iptables -A INPUT -p tcp --dport 6443 -j ACCEPT

# Open TCP/6443 for one specific IP
iptables -A INPUT -p tcp -s your_ip_here --dport 6443 -j ACCEPT

```

## firewall Open
```bash
# Open TCP/6443 for all
firewall-cmd --zone=public --add-port=6443/tcp --permanent
firewall-cmd --reload

# Open TCP/6443 for one specific IP
#firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="your_ip_here/32"
  port protocol="tcp" port="6443" accept'
  
#firewall-cmd --reload
```

$TTL    604800
@       IN      SOA     ns1.byteworksinc.com. ubuntu.byteworksinc.com. (
                              7         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; name servers - NS records
@       IN      NS      ns1.byteworksinc.com.
@       IN      NS      ns2.byteworksinc.com.

; name servers - A records
ns1.byteworksinc.com.   IN      A       10.0.0.8
ns2.byteworksinc.com.   IN      A       10.0.0.9

; 10.0.0.0/16 - A records

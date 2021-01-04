**This example is used for functional verification and is not recommended for performance testing. For performance testing, please refer to [benchmark](https://github.com/apache/apisix#benchmark) .**

### Run

```
$ docker-compose -p docker-apisix up -d
```

### Configure

```
curl http://127.0.0.1:9080/apisix/admin/services/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "172.18.5.12:80": 1
        }
    }
}'

curl http://127.0.0.1:9080/apisix/admin/services/2 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "172.18.5.13:80": 1
        }
    }
}'

curl http://127.0.0.1:9080/apisix/admin/routes/12 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "uri": "/*",
    "host": "web1.lvh.me",
    "service_id": "1"
}'

curl http://127.0.0.1:9080/apisix/admin/routes/22 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "uri": "/*",
    "host": "web2.lvh.me",
    "service_id": "2"
}'

curl http://127.0.0.1:9080/apisix/admin/ssl/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d "
{
    \"cert\": \"$( cat './mkcert/lvh.me+1.pem')\",
    \"key\": \"$( cat './mkcert/lvh.me+1-key.pem')\",
    \"sni\": \"lvh.me\"
}"

curl http://127.0.0.1:9080/apisix/admin/ssl/2 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d "
{
    \"cert\": \"$( cat './mkcert/lvh.me+1.pem')\",
    \"key\": \"$( cat './mkcert/lvh.me+1-key.pem')\",
    \"sni\": \"*.lvh.me\"
}"
```

### Test

When testing subdomains, using localhost is not a good option. Due to this, lets use [http://lvh.me/](http://lvh.me/)
free service to resolve itself along with all subdomains to localhost.

```
curl http://web1.lvh.me:9080/hello -v # hello web1

curl http://web2.lvh.me:9080/hello -v # hello web2
```

```
curl https://web1.lvh.me:9443/ -v --cacert ./mkcert/rootCA.pem
```

### Clean

```
$ docker-compose -p docker-apisix down

$ sudo rm -rf etcd_data/member

$ rm -rf apisix_log/*.log
```

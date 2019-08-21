### Run

```
$ docker-compose -p docker-apisix up -d
```

### Configure

```
curl http://127.0.0.1:9080/apisix/admin/services/1 -X PUT -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "127.0.0.1:9081": 1
        }
    }
}'

curl http://127.0.0.1:9080/apisix/admin/services/2 -X PUT -d '
{
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "127.0.0.1:9082": 1
        }
    }
}'

curl http://127.0.0.1:9080/apisix/admin/routes/11 -X PUT -d '
{
    "uri": "/",
    "host": "web1.lvh.me",
    "service_id": "1"
}'

curl http://127.0.0.1:9080/apisix/admin/routes/12 -X PUT -d '
{
    "uri": "/{:.*}",
    "host": "web1.lvh.me",
    "service_id": "1"
}'

curl http://127.0.0.1:9080/apisix/admin/routes/21 -X PUT -d '
{
    "uri": "/",
    "host": "web2.lvh.me",
    "service_id": "2"
}'

curl http://127.0.0.1:9080/apisix/admin/routes/22 -X PUT -d '
{
    "uri": "/{:.*}",
    "host": "web2.lvh.me",
    "service_id": "2"
}'

curl http://127.0.0.1:9080/apisix/admin/ssl/1 -X PUT -d "
{
    \"cert\": \"$( cat './mkcert/lvh.me+1.pem')\",
    \"key\": \"$( cat './mkcert/lvh.me+1-key.pem')\",
    \"sni\": \"lvh.me\"
}"

curl http://127.0.0.1:9080/apisix/admin/ssl/2 -X PUT -d "
{
    \"cert\": \"$( cat './mkcert/lvh.me+1.pem')\",
    \"key\": \"$( cat './mkcert/lvh.me+1-key.pem')\",
    \"sni\": \"*.lvh.me\"
}"
```

### Test

```
curl http://web1.lvh.me:9080/ -v # web1.txt
curl http://web1.lvh.me:9080/web1.txt -v # web1

curl http://web2.lvh.me:9080/ -v # web2.txt
curl http://web2.lvh.me:9080/web2.txt -v # web2
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

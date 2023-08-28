## 如何在容器化环境调试PISIX
> 使用过程中有问题可以参考 [样例项目](https://github.com/cj2a7t/apisix-docker-debugger)
### 1.为什么要在容器化环境调试？
由于[Mac M1 make run error ](https://github.com/apache/apisix/issues/7313)、每个开发环境(windows、ubuntu、mac、mac m1等等)本地源码安装方式的差异、没有单步调试的直接方式等问题。我们想搭建一套可以单步调试的Apisix开发环境，需要查阅很多资料，而且资料特别分散。所以想在Apisix Dokcer仓库基于debian-dev提供一种快速的搭建本地开发环境的方式。下面以VS code为例来搭建一套Apisix的开发环境。
### 2.开发环境全景图
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e1115731c7bd44b8ab800c96de5a6ed2~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=2166&h=902&e=png&b=fefcfc)
### 3.扩展构建步骤说明
#### 3.1 构建镜像
debian-emmy中的docker-compose.yaml中配置的镜像是已经构建好的镜像(可以直接使用)，如果有其他需求可以采用下面的步骤，本地重新构建apisix-emmy镜像，用于本地调试使用。
```dockerfile
services:
  apisix:
    # [Debian Emmy]: This is a built emmy debug image that includes /usr/local/emmy.so. 
    # [Debian Emmy]: If there is no special version available, you can use this version directly.
    # [Debian Emmy]: If there is a need for customization.
    # [Debian Emmy]: Build an image version based on the ./image/Dockerfile
    # [Debian Emmy]: TAG: arm or amd
    image: "coderjia/apisix-emmy:${TAG}"
```
在Debian-Emmy文件夹image目录下的Dockerfile，相对于官方的debian-dev新增如下内容，主要目的是将`emmy_core.so`文件直接生成到容器内的/usr/local/emmy/目录下，如果后续想升级emmy的debug版本，可以自行调整。然后构建出新的镜像。
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/28c1e09877af422bac9a22d8697711ae~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1712&h=1728&e=png&b=101216)
#### 3.2 准备调试的源码
将自己的定制化版本的apisix源码，放置到这个目录中，如果你需要官方版本的代码学习，那可以直接拉取官方的源码目录代码。切记：是源码目录，不包含构建文件的目录。
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86386ba88ef8455cb178f57d87a31dd4~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=952&h=334&e=png&b=04080c)
将`./emmy/emmy-debugger.lua`插件拷贝到./apisix/plugins目录下，这个就是全景图中绿色的插件，用于容器内加载emmy debug。
#### 3.3 配置调整
a. 调整./apisix_conf/config.yaml中的fix_path，调整为你本地的源码绝对路径目录。
```yaml
# [Debian Emmy]: It is only recommended to start one worker in the debug environment.
nginx_config:
  worker_processes: 1
# [Debian Emmy]: Loading emmy debugger.lua during the startup of Apisix is the key to emmy dbg listening and hooking(fix path).
plugins:
  - emmy-debugger                        # priority: 50000
# [Debian Emmy]: The fixPath function retrieves the path of the file and "fixes" it to the path expected by VS Code.
plugin_attr:
  emmy-debugger:
    fix_path: ${prefix}/apisix
    port: 9966
```
b. 如果有需要挂载新的目录，调整docker-compose.yaml中的挂载目录。
```yaml
    volumes:
      - ./apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml:ro
      # [Debian Emmy]: Customized version of Apisix source code
      - ./apisix:/usr/local/apisix/apisix:ro
      # [Debian Emmy]: When customizing code, you can volume it in more directories.
```
#### 3.4 启动debug环境
a. 先启动Apisix相关的容器
```docker
# Version needs to be adjusted independently  arm or amd
TAG=amd docker-compose up -d
```
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bed6ce4af3cb4959bc9f8227924bd8e1~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1922&h=218&e=png&b=01050b)
查看日志，看emmy dbg是否已经开启监听
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6b2033beef334e42b7487efad259af5b~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1532&h=486&e=png&b=01050c)
b. 在VS Code中安装Emmy Lua插件
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92383875ad134b2ebb64b492b60656d1~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=950&h=150&e=png&b=0e1217)
c. 配置 EmmyLua插件
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d91eff32757740ccb81e53406cf4e01e~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1044&h=488&e=png&b=04080c)
选择EmmyLua New Debugger
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b9e771a07b54ef5bd3a9776a2307d75~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1214&h=654&e=png&b=15181e)
添加一行preLaunchTask
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f9633a9c201644b5a29aa17bf3cfa0a0~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1914&h=766&e=png&b=13151a)
在.vscode创建个tasks.json，主要是为了debug之前重启下容器，避免代码缓存导致debug没有到新增的代码，还有一种方式是 [关闭lua code cache](https://openresty-reference.readthedocs.io/en/latest/Directives/#lua_code_cache)。另外task的command是以unix的系统为例，在windows系统里，可以调整为powershell。
```json
// unix
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "restartAndDelay",
            "type": "shell",
            "command": "sh",
            "args": [
                "-c",
                "docker restart ${apisix_container_name} && sleep 3"
            ]
        }
    ]
}
// windows
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "restartAndDelay",
            "type": "shell",
            "command": "powershell",
            "args": [
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-Command", "docker restart ${apisix_container_name}; Start-Sleep -Seconds 3"
            ]
        }
    ]
}
```
d. 开始debug验证，在init.lua的access阶段加个断点
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3fc6f3be29814e019d18a3f669b3f7d8~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=2626&h=1558&e=png&b=121418)
VS Code启动监听
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04233b16c34d4d8caf235370c70cface~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=4090&h=382&e=png&b=191c21)
创建个测试路由，并调用路由
```sh
# create a new route
curl -X PUT \
  http://localhost:9180/apisix/admin/routes/1 \
  -H 'Content-Type: application/json' \
  -H 'x-api-key: edd1c9f034335f136f87ad84b625c8f1' \
  -d '{
    "uri": "/get",
    "plugins": {},
    "upstream": {
        "pass_host": "node",
        "type": "roundrobin",
        "nodes": {
            "httpbin.org": 1
        }
    }
}'
# call route
curl --location 'http://localhost:9080/get'
```
当调用路由后，可以看到已经debug成功
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f526712d16c40068b189dda49feb910~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=4476&h=1712&e=png&b=16191e)
### 相关资料
- https://github.com/EmmyLua/EmmyLuaDebugger
- https://github.com/apache/apisix/issues/7313
- https://github.com/openresty/lua-nginx-module/pull/2037
- https://dev.to/omervk/debugging-lua-inside-openresty-inside-docker-with-intellij-idea-2h95
- https://github.com/apache/apisix-docker

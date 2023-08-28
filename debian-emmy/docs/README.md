## How to Debug APISIX in a Containerized Environment
> If there are any problems during the use process, please refer to the [sample project](https://github.com/cj2a7t/apisix-docker-debugger).
### 1.Why Debug in a Containerized Environment?
Due to issues such a[Mac M1 make run error ](https://github.com/apache/apisix/issues/7313) differences in local source code installation methods for various development environments (Windows, Ubuntu, macOS, Mac M1, etc.), and the lack of a straightforward way for step-by-step debugging, setting up a development environment for APISIX with debugging capabilities requires a lot of scattered information. To address this, a fast way to establish a local development environment for APISIX is provided in the APISIX Docker repository based on debian-dev. The following guide demonstrates setting up an APISIX development environment using VS Code.
### 2.Development Environment Overview
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e1115731c7bd44b8ab800c96de5a6ed2~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=2166&h=902&e=png&b=fefcfc)
### 3.Steps to Build the Environment
#### 3.1 Build the Docker Image
In the docker-compose.yaml file in the debian-emmy folder, you can use the pre-built image directly. However, if you have specific requirements, you can follow the steps below to build a custom apisix-emmy image for local debugging.
```dockerfile
services:
  apisix:
    # [Debian Emmy]: This is a built emmy debug image that includes /usr/local/emmy.so. 
    # [Debian Emmy]: If there is no special version available, you can use this version directly.
    # [Debian Emmy]: If there is a need for customization.
    # [Debian Emmy]: TAG: arm or amd
    image: "coderjia/apisix-emmy:${TAG}"
```
In the Dockerfile under the image directory in the debian-emmy folder, add the following lines to generate the emmy_core.so file directly into the /usr/local/emmy/ directory within the container. This is useful if you want to upgrade the debug version of Emmy later. Then build the new image.
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/28c1e09877af422bac9a22d8697711ae~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1712&h=1728&e=png&b=101216)
#### 3.2 Prepare Debuggable Source Code
Place your customized version of the APISIX source code into this directory. If you wish to use the official codebase for learning purposes, you can directly clone the official repository. Remember that this should be the source code directory, excluding the build files.
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86386ba88ef8455cb178f57d87a31dd4~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=952&h=334&e=png&b=04080c)
Copy the`./emmy/emmy-debugger.lua`plugin to the `./apisix/plugins` directory. This plugin is responsible for loading the Emmy debugger within the container.
#### 3.3 Adjust Configuration
a.Modify the `./apisix_conf/config.yaml`in`fix_path`，to the absolute path of your local source code directory.
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
b. If you need to mount additional directories, adjust the mount paths in the docker-compose.yaml file.
```yaml
    volumes:
      - ./apisix_conf/config.yaml:/usr/local/apisix/conf/config.yaml:ro
      # [Debian Emmy]: Customized version of Apisix source code
      - ./apisix:/usr/local/apisix/apisix:ro
      # [Debian Emmy]: When customizing code, you can volume it in more directories.
```
#### 3.4 Start the Debug Environment
a. Start the APISIX-related containers.
```docker
# Version needs to be adjusted independently  arm or amd
TAG=amd docker-compose up -d
```
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bed6ce4af3cb4959bc9f8227924bd8e1~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1922&h=218&e=png&b=01050b)
Check the logs to ensure that the Emmy debugger is listening.
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6b2033beef334e42b7487efad259af5b~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1532&h=486&e=png&b=01050c)
b. Install the Emmy Lua plugin in VS Code.
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92383875ad134b2ebb64b492b60656d1~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=950&h=150&e=png&b=0e1217)
c. Configure the EmmyLua plugin.
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d91eff32757740ccb81e53406cf4e01e~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1044&h=488&e=png&b=04080c)
Select the EmmyLua New Debugger.
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b9e771a07b54ef5bd3a9776a2307d75~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1214&h=654&e=png&b=15181e)
Add a preLaunchTask line.
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f9633a9c201644b5a29aa17bf3cfa0a0~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1914&h=766&e=png&b=13151a)
Create a tasks.json in the .vscode directory. This is primarily done to restart the container before debugging, preventing code caching from causing the debugger to miss newly added code. Another approach is to [disable Lua code cache](https://openresty-reference.readthedocs.io/en/latest/Directives/#lua_code_cache). Additionally, note that the command in the task is an example for Unix-like systems, and on Windows systems, it can be adjusted to PowerShell.
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
d. Start debugging by adding breakpoints in the source code. Use the VS Code debugger to initiate the debugging process.
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3fc6f3be29814e019d18a3f669b3f7d8~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=2626&h=1558&e=png&b=121418)
Start listening in VS Code.
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04233b16c34d4d8caf235370c70cface~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=4090&h=382&e=png&b=191c21)
Create a test route and invoke the route.
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
After invoking the route, you will observe a successful debugging session.
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f526712d16c40068b189dda49feb910~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=4476&h=1712&e=png&b=16191e)
### References
- https://github.com/EmmyLua/EmmyLuaDebugger
- https://github.com/apache/apisix/issues/7313
- https://github.com/openresty/lua-nginx-module/pull/2037
- https://dev.to/omervk/debugging-lua-inside-openresty-inside-docker-with-intellij-idea-2h95
- https://github.com/apache/apisix-docker

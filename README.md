# portable-chrome

在当前目录生成便携式的 Chrome 浏览器。

所谓便携式，是指可以将其拷贝到任何计算机的任何路径下，都可以正常使用。

只支持 Windows 系统。

## 使用

在希望创建环境的目录中使用 PowerShell 执行以下命令：

```
irm "https://raw.githubusercontent.com/one-click-run/portable-chrome/main/init.ps1" | iex
```

也可以直接指定 Chrome 版本：

```
$env:ONE_CLICK_RUN_PORTABLE_CHROME_SELECTEDMATCH = 'chrome-74.zip'; irm 'https://raw.githubusercontent.com/one-click-run/portable-chrome/main/init.ps1' | iex
```

## 说明

本仓库提供的 zip 包是通过从官方 Chrome 安装包解压并重新打包为 zip 得到的。

如果你不信任我提供的文件，可以使用地址:

```
https://dl.google.com/chrome/install/standalonesetup64.exe?version=<version>
```

其中, version 是你想要的版本, 例如 74.

然后将其解压, 并重新打包为 zip 即可.

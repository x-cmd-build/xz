# xz — 便携二进制发行版

打包自 **[xz-utils](https://github.com/tukaani-project/xz)** **5.8.3**（已修复 [CVE-2024-3094](https://www.cve.org/CVERecord?id=CVE-2024-3094) 后门漏洞）—— 为 `x-cmd` 包生态提供的便携二进制发行版。

## 安装

```sh
# macOS / Linux（有 `x` 命令）：
x eget x-cmd-build/xz --to /usr/local/bin/xz

# 手动：
# 1. 打开 https://github.com/x-cmd-build/xz/releases
# 2. 下载匹配你平台的 asset
# 3. 解压，把 `xz`（或 `xz.exe`）放到 PATH
```

### 资产命名

| 文件 | 平台 |
|---|---|
| `xz-linux-musl-x64.tar.xz` | x86_64 Linux（Alpine / glibc，静态链接）|
| `xz-linux-musl-arm64.tar.xz` | aarch64 Linux |
| `xz-darwin-x64.tar.xz` | x86_64 macOS |
| `xz-darwin-arm64.tar.xz` | Apple Silicon macOS |
| `xz-windows-x64.zip` | x86_64 Windows（MSYS）|

每个压缩包都包含 `bin/xz`（Windows 是 `bin/xz.exe`）以及 `LICENSE`、`NOTICE.md`、本 README。

## 使用

```sh
# 压缩 / 解压
xz file.txt            # → file.txt.xz（删除原文件）
xz -d file.txt.xz      # → file.txt
xz -k file.txt         # 保留原文件
xz -9 file.txt         # 最高压缩率

# 流式
tar -cf - src/ | xz > src.tar.xz
xz -dc src.tar.xz | tar -xf -
```

## CVE-2024-3094 状态

xz-utils 5.6.0 和 5.6.1 包含恶意后门（CVE-2024-3094）。
**5.8.3 已修复**——在 bootstrap 时通过源码审查验证（详见
[`security-review.md`](security-review.md)）。

我们 pin 到 5.8.3+ 来彻底避开 CVE-2024-3094 影响范围（5.6.0、5.6.1）。
升级策略：

| 范围 | 状态 |
|---|---|
| ≤ 5.4.x | CVE 之前，upstream 支持 |
| 5.5.x | CVE 之前，upstream 支持 |
| 5.6.0、5.6.1 | **CVE-2024-3094 —— 切勿使用** |
| 5.6.2+ | CVE 修复后，安全 |
| 5.8.x | 当前，推荐 |

## 许可证

- **本发行版** (`x-cmd-build/xz`): BSD-3-Clause（我们的封装）
- **xz-utils** 本身：混合许可——见 `NOTICE.md` 和 `upstream/xz/COPYING*`

## 另见

- xz-utils 上游：<https://github.com/tukaani-project/xz>
- CVE-2024-3094 公告：<https://www.cve.org/CVERecord?id=CVE-2024-3094>
- English README: [README.md](README.md)
- 设计中枢：<https://github.com/x-cmd-build/mneme>（私有）
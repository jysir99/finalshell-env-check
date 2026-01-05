# finalshell-env-check

一个轻量级的用户级预检脚本，用于检测 Linux 环境是否兼容 **FinalShell 服务器监控**。

本项目帮助识别导致 FinalShell 显示**异常或空服务器指标**的*环境问题*（缺失命令、受限的 `/proc`、locale 问题等）。

---

## 🚀 使用方法

### 方式一：一键运行（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/jysir99/finalshell-env-check/main/check_finalshell_env.sh | bash
```

或者使用 wget：

```bash
wget -qO- https://raw.githubusercontent.com/jysir99/finalshell-env-check/main/check_finalshell_env.sh | bash
```

### 方式二：下载后运行

```bash
git clone https://github.com/jysir99/finalshell-env-check.git
cd finalshell-env-check
chmod +x check_finalshell_env.sh
./check_finalshell_env.sh
```

---


## 🔍 检测内容

基于对 FinalShell 行为的实际逆向分析，本脚本验证：

- 必需的命令：
  - `bash`
  - `free`
  - `uptime`
  - `df`
- 文件读取权限：
  - `/proc/net/dev`
- Locale 兼容性（`en_US`）
- FinalShell 监控命令序列的端到端模拟

如果**任何要求失败**，FinalShell 的服务器信息面板可能会出现问题。

---

## ✅ 示例：成功输出

```text
==========================================
FinalShell Environment Compatibility Check
==========================================

Checking required commands...
[ OK ] command 'bash' exists
[ OK ] command 'free' exists
[ OK ] command 'uptime' exists
[ OK ] command 'df' exists

Checking file access...
[ OK ] file '/proc/net/dev' is readable

Checking locale compatibility...
[ OK ] locale 'en_US' is available

Simulating FinalShell monitoring sequence...
[ OK ] FinalShell core data collection succeeded

==========================================
✅ Environment is compatible with FinalShell server monitoring
```

---

## ❌ 示例：失败（缺少 uptime）

```text
==========================================
FinalShell Environment Compatibility Check
==========================================

Checking required commands...
[ OK ] command 'bash' exists
[ OK ] command 'free' exists
[FAIL] command 'uptime' NOT found
[ OK ] command 'df' exists

Checking file access...
[ OK ] file '/proc/net/dev' is readable

Checking locale compatibility...
[ OK ] locale 'en_US' is available

Simulating FinalShell monitoring sequence...
[FAIL] FinalShell core data collection failed (exit code=101)

==========================================
❌ Environment is NOT compatible with FinalShell server monitoring

Failure reasons:
  • Missing command: uptime
  • uptime command failed
```

---

## 🧠 为什么需要这个工具

FinalShell 的服务器监控面板依赖于**通过 SSH 执行系统命令**并解析其输出。在最小化、加固、容器化或配置错误的系统中，这些假设经常会被打破。

与其猜测或责怪 FinalShell，本脚本提供了一个**确定且可复现的检查**。


---

## 📜 许可证

MIT License


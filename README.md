# RepairAgent 环境部署与复现指南

本仓库用于记录和自动化部署 `RepairAgent` (v0.6.5) 及其依赖 (`Defects4J`, `Java 11`, `Python 3.11`) 在 Windows (WSL2 Ubuntu) 下的完整过程。

**⚠️ 注意**：本仓库不包含 `RepairAgent` 和 `Defects4J` 的源码（请从原作者仓库拉取），仅包含环境依赖、排坑日志与一键部署脚本。

## 🚀 快速开始 (一键部署)

如果你在 WSL2 (Ubuntu) 环境下，并且已经拉取了 `RepairAgent` 源码，可以直接运行以下命令：

```bash
# 1. 克隆本环境配置仓库（假设克隆到当前目录）
git clone https://github.com/Unlimitedlearning/RepairAgent-Replication-Package.git env-config

# 2. 将脚本和锁文件拷贝到项目根目录
cp env-config/setup_env.sh ./RepairAgent/repair_agent/
cp env-config/requirements-lock.txt ./RepairAgent/repair_agent/

# 3. 运行脚本
cd RepairAgent/repair_agent
chmod +x setup_env.sh
./setup_env.sh
```

## 📂 文件说明

- `setup_env.sh`：一键自动安装系统依赖 (Perl, JDK 11 等)、Miniconda，并利用阿里云镜像安装锁定版本的 Python 依赖。
- `requirements-lock.txt`：**核心文件**。包含完全测试通过的 Python 包精确版本号（解决 `openai==0.27.8` 与 `langchain` 历史遗留冲突）。
- `docs/Python配置过程.md`：记录了 Python 3.11 环境配置、PEP 668 报错、依赖回溯（Backtracking）冲突的详细排坑过程。
- `docs/指令操作记录.md`：记录了 Defects4J 初始化、CRLF 换行符修复、Perl 模块补装的完整指令。

## 🔑 启动前准备

在启动 `python repairagent.py` 之前，请确保你已经配置了 API Key（不要在代码或提交记录中泄露你的 Key）。

---
Maintained by Unlimitedlearning, initial setup log created on 2026-11-09.
---


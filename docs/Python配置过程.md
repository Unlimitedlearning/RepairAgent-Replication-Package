# RepairAgent Python 环境配置与依赖安装日志

**系统环境**：WSL2 Ubuntu (默认自带 Python 3.14)
**最终目标**：构建 Python 3.11 专属环境，并解决复杂的依赖冲突，确保 100% 开源合规。
**记录时间**：2026-11-09

---

## 一、 初始尝试与失败教训

### 1. 系统 Python 3.14 的 PEP 668 限制
- **报错**：`externally-managed-environment`。
- **原因**：Ubuntu 禁止直接使用 `pip` 安装系统级包。
- **尝试**：使用 `python3 -m venv .venv` 创建虚拟环境。
- **新问题**：系统是 Python 3.14，部分包（如 `spacy`, `blis`）无预编译 `.whl`，导致从源码编译时报错：`Build aborted: the NumPy Cython headers require Cython 3.0.0 or newer`。

### 2. 为什么不使用系统 `apt` 安装 Python 3.11？
- `apt` 源中无 `python3.11`，添加 deadsnakes PPA 时常因网络问题卡顿或 403 Forbidden。

---

## 二、 转向 Miniconda + Python 3.11

### 1. 安装 Miniconda
- 放弃了龟速的官方源，改用国内镜像站（如北大、中科大）。
- **注意**：清华镜像站有时会对 `wget` 返回 403 错误，建议多备几个源。
```bash
wget -c https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -u
~/miniconda3/bin/conda init bash
source ~/.bashrc
```

### 2. 解决 Conda ToS（服务条款）与合规化改造
- **报错**：`CondaToSNonInteractiveError: Terms of Service have not been accepted`。
- **原因**：Anaconda 对其官方的 `defaults` 频道增加了商业使用限制。
- **合规化解决**：彻底移除官方源，改用社区驱动的 `conda-forge`，并强制设置 `nodefaults`。
```bash
conda config --remove-key channels
conda config --add channels conda-forge
conda config --append channels nodefaults
```
*(验证 `~/.condarc` 文件中只包含上述配置，即可完全规避商业条款限制)*

### 3. 创建 Python 3.11 环境
强制使用 `--override-channels` 覆盖所有潜在配置，确保彻底断开官方源：
```bash
conda create -n repairagent python=3.11 -c conda-forge --override-channels -y
conda activate repairagent
```
*(注：激活后必须确认 `python --version` 输出 3.11.x)*

---

## 三、 攻克 requirements-core.txt 的依赖死结

使用 pip 安装时，经历了极其痛苦的**依赖回溯（Backtracking）**，`pip` 疯狂下载历代版本（如 `httpcore`, `langsmith`, `huggingface_hub`）。原因在于项目文件中的 `openai==0.27.8`（极老）与未限版本的 `langchain`（默认拉取最新）发生严重冲突。

### 1. 网络问题处理
- **GitHub 超时**：`en-core-web-sm` 模型下载超时。修改链接，加上代理前缀（如 `https://githubproxy.cc/`）。
- **Git 克隆失败**：`auto-gpt-plugin-template` 使用 `ghproxy.net` 代理时报 `exit code: 128`。**解决**：更换为 `https://githubproxy.cc/` 代理，并在前缀后加上 GitHub 原链接，最终成功通过代理拉取。

### 2. 彻底锁死版本（最终决胜方案）
在 `requirements-core.txt` 中**强制锁定**特定版本，彻底掐断冲突的可能，并生成了最终的 `requirements-lock.txt`。

### 3. 最终安装命令
使用阿里云镜像加速，并使用虚拟环境内的 `python -m pip` 进行安装。
```bash
python -m pip install -r requirements-lock.txt -i https://mirrors.aliyun.com/pypi/simple/
```
*(注：安装成功后，可能会提示 `wheel 0.48.0 requires packaging>=24.0` 的红色警告，这是因为锁死了老版 `packaging`，此为无害警告，直接无视即可。)*

---

## 四、 最终验证

运行启动命令：
```bash
python repairagent.py
```
环境检查全部 `OK`（Python 3.10+: 3.11.18, Java 11, Perl, SVN, Defects4J, Python packages 全绿）。

---

## 附录：最终成功的 requirements-core.txt 内容

```text
# Core requirements for running RepairAgent.
httpx==0.24.1
pydantic==1.10.13
langsmith==0.1.17
huggingface_hub==0.23.4
# For the full set (dev tools, analysis, docs): pip install -r requirements.txt

# CLI and display
click
rich>=13.0.0
colorama==0.4.6

# LLM providers
openai==0.27.8
anthropic==0.23.1
tiktoken
langchain==0.1.16
langchain-anthropic==0.1.9

# Configuration and serialization
python-dotenv==0.21
pyyaml>=6.0.1
jsonschema
orjson>=3.9.14
json-repair
distro==1.8.0

# Code analysis (Java parsing)
javalang
antlr4-python3-runtime

# Text processing
beautifulsoup4>=4.12.2
charset-normalizer>=3.1.0
ftfy>=6.1.1
requests
fuzzywuzzy
spacy>=3.7.0,<4.0.0
en-core-web-sm @ https://githubproxy.cc/https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl

# Agent framework
prompt_toolkit>=3.0.38
inflection
gitpython==3.1.31
auto-gpt-plugin-template @ git+https://githubproxy.cc/https://github.com/Significant-Gravitas/Auto-GPT-Plugin-Template@0.1.0

# Audio (imported by app/main.py even when speak_mode=False)
gTTS==2.3.1
playsound==1.2.2

# Defects4J experiment support
whatthepatch
```


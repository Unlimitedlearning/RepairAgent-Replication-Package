#!/bin/bash

# 遇到错误立即退出
set -e

echo "=================================================="
echo "  RepairAgent 环境一键配置脚本 (WSL Ubuntu)"
echo "=================================================="

# 1. 安装系统级依赖
echo "[1/4] 正在检查并安装系统依赖 (需要 sudo 权限)..."
sudo apt-get update
sudo apt-get install -y perl cpanminus subversion unzip zip curl wget openjdk-11-jdk build-essential

# 配置 Java 11 环境变量
if ! grep -q "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" ~/.bashrc; then
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
fi

# 2. 检查并安装 Miniconda
echo "[2/4] 正在检查 Miniconda..."
if [ ! -d "$HOME/miniconda3" ]; then
    echo "未找到 Miniconda，正在从北大镜像站下载并静默安装..."
    wget -c https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -u
    ~/miniconda3/bin/conda init bash
    echo "Miniconda 安装完成。"
else
    echo "Miniconda 已存在，跳过安装。"
fi

# 确保 conda 命令可用
source ~/miniconda3/etc/profile.d/conda.sh

# 配置 conda 渠道：移除 defaults，加入 nodefaults 和 conda-forge，规避商业条款
echo "配置 Conda 渠道 (100% 开源合规)..."
conda config --remove-key channels || true
conda config --add channels conda-forge
conda config --append channels nodefaults

# 3. 创建并激活 Conda 环境
echo "[3/4] 正在创建 Python 3.11 虚拟环境..."
if ! conda env list | grep -q "repairagent"; then
    # 强制只使用 conda-forge
    conda create -n repairagent python=3.11 -c conda-forge --override-channels -y
else
    echo "环境 repairagent 已存在，跳过创建。"
fi

conda activate repairagent

# 4. 安装 Python 依赖
echo "[4/4] 正在使用阿里云镜像安装锁定版本的 Python 依赖..."
python -m pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/

if [ -f "requirements-lock.txt" ]; then
    echo "检测到 requirements-lock.txt，将安装完全锁定的版本。"
    python -m pip install -r requirements-lock.txt -i https://mirrors.aliyun.com/pypi/simple/
else
    echo "未找到 lock 文件，使用 requirements-core.txt 安装。"
    python -m pip install -r requirements-core.txt -i https://mirrors.aliyun.com/pypi/simple/
fi

echo "=================================================="
echo "🎉 环境配置全部完成！"
echo "接下来请执行以下命令启动程序："
echo "  conda activate repairagent"
echo "  python repairagent.py"
echo "=================================================="
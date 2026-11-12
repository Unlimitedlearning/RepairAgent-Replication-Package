

# 📄 运行与 API 配置指南
---

# RepairAgent 运行与 API 配置指南

本文档记录了如何启动 RepairAgent，以及如何配置 DeepSeek API（利用 OpenAI 兼容接口）供 Agent 使用。

## 🚀 1. 启动 RepairAgent

由于系统默认自带 Python 3.14，**每次启动前必须手动激活我们配置好的 Python 3.11 环境**，否则会导致依赖包编译报错或无法加载。

在 WSL 终端依次执行以下命令：

```bash
# 1. 激活 Python 3.11 环境 (终端提示符前应出现 `(repairagent)`)
conda activate repairagent

# 2. 进入项目目录
cd /mnt/d/GithubProgram/APR_Research/RepairAgent/repair_agent

# 3. 启动程序
python repairagent.py

# 4. 启动后的交互式菜单输入参考：
# [7] Custom model -> 输入: deepseek-chat
# Temperature (0.0) -> 直接回车
# Method [1/2/3] (1): 输入 1 (手动输入)
# Enter bugs: 输入 Lang 1
# Max cycles per bug (40): 输入 10

```

---

## 🔑 2. 配置 DeepSeek API Key (利用 OpenAI 兼容接口)

由于 RepairAgent 原生依赖 `openai==0.27.8`，而 DeepSeek 的 API 完全兼容 OpenAI 接口规范，我们可以通过设置环境变量，让 RepairAgent 无缝使用 DeepSeek 的模型。

在 WSL 终端中执行以下命令，创建并配置环境变量文件：

```bash
cat > ~/.deepseek_env <<'EOF'
# 请将下面的占位符替换为你真实的 DeepSeek 密钥
export DEEPSEEK_API_KEY="sk-你的真实DeepSeek密钥"
export OPENAI_API_KEY="$DEEPSEEK_API_KEY"
export OPENAI_BASE_URL="https://api.deepseek.com"
export OPENAI_MODEL="deepseek-chat"
EOF

# 设置文件权限，防止其他用户读取（包含敏感信息）
chmod 600 ~/.deepseek_env

# 将环境变量加载命令写入 .bashrc，使其每次打开终端自动生效
echo 'source ~/.deepseek_env' >> ~/.bashrc

# 立即生效
source ~/.bashrc
```

### 💡 验证配置是否成功
配置完成后，可以运行以下命令验证环境变量是否已加载：
```bash
echo $OPENAI_BASE_URL  # 应输出 https://api.deepseek.com
echo $OPENAI_MODEL     # 应输出 deepseek-chat
```

### ⚠️ 安全与提示
1. **绝对不要**把真实的 API Key 直接写死在代码里，或者提交到 GitHub 仓库中。
2. 如果运行 `python repairagent.py` 时，环境检查提示 `MISSING API key`，你可以直接在终端交互界面粘贴你的 Key，或者在项目根目录创建一个 `.env` 文件写入 `OPENAI_API_KEY=你的key`。
3. 当前配置使用 `deepseek-chat` 模型，如果需要更好的代码能力，可将其替换为 `deepseek-coder`。



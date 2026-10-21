# Docker 部署

镜像 `ghcr.io/robotrunm2/mimotion`，用 Nuitka 编译成单个二进制，容器内由 supercronic 常驻定时执行。

## 镜像构建

工作流 `.github/workflows/docker.yml`（Actions 页名称 `同步上游并构建镜像`）每天北京时间 04:00 自动：

1. 同步上游 `TonyJiangWJ/mimotion`（GitHub `merge-upstream` API，等同网页上的 Sync fork）
2. 构建并推送 `ghcr.io/robotrunm2/mimotion:latest` 和 `:YYYYMMDD`

前提：

- 仓库 Secrets 已配置 `PAT`（创建方法见 README「一、Fork 此仓库，然后创建token」，需 Contents 和 Workflows 读写权限）
- 仓库 Actions 已启用

也可以在 Actions 页手动 `Run workflow`。首次推送后 GHCR 包默认是私有的，需要到 GitHub 个人主页 → Packages → mimotion → Package settings 把可见性改成 Public，或者在部署机上先 `docker login ghcr.io`。

同步产生冲突时 `sync` 步骤会失败、构建被跳过，需要在仓库网页点 Sync fork 手动解决冲突后再手动运行工作流。

## 部署

```bash
mkdir mimotion && cd mimotion
curl -fsSLO https://raw.githubusercontent.com/RobotRunM2/mimotion/master/docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/RobotRunM2/mimotion/master/.env.example -o .env
# 编辑 .env 填写账号密码等
docker compose up -d
docker compose logs -f
```

## 配置

账号、密码、步数、推送等变量的含义与 `.env.example` 一致，写在 `.env` 里。

- `CRON`：北京时间 cron 表达式（分 时 日 月 周），默认 `23 18,20,22 * * *`，在 `docker-compose.yml` 的 `environment` 中修改。
- `TZ`：默认 `Asia/Shanghai`。
- 步数按北京时间比例计算，22 点后才是满额，所以不建议把执行时间设得太早。

## 手动执行一次

```bash
docker compose run --rm mimotion /app/mimotion
```

## 数据

`./data` 挂载到容器 `/data`（容器工作目录）。配置了 `AES_KEY` 后，token 加密保存在 `./data/encrypted_tokens.data`。

## 更新镜像

```bash
docker compose pull && docker compose up -d
```

## 本地构建（可选）

```bash
docker build -t mimotion .
```

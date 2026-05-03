# LobeHub Helm Chart

基于 `docker-compose/deploy` 配置生成的 Kubernetes Helm Chart。

## 组件

| 组件 | 描述 | 默认启用 |
|------|------|----------|
| **LobeHub** | AI 聊天主应用 | ✅ |
| **PostgreSQL** | 数据库 (paradedb/paradedb) | ✅ |
| **Redis** | 缓存与会话存储 | ✅ |
| **RustFS** | S3 兼容对象存储 | ✅ |
| **SearXNG** | 搜索引擎 | ✅ |

## 快速开始

```bash
# 1. 生成密钥
export KEY_VAULTS_SECRET=$(openssl rand -base64 32)
export AUTH_SECRET=$(openssl rand -base64 32)
export POSTGRES_PASSWORD=$(openssl rand -base64 16)
export RUSTFS_SECRET_KEY=$(openssl rand -base64 16)

# 2. 安装
helm install lobehub ./helm \
  --set secrets.keyVaultsSecret=$KEY_VAULTS_SECRET \
  --set secrets.authSecret=$AUTH_SECRET \
  --set postgresql.password=$POSTGRES_PASSWORD \
  --set rustfs.secretKey=$RUSTFS_SECRET_KEY

# 3. 访问
kubectl port-forward svc/lobehub 3210:3210
```

## 使用生产环境配置

```bash
# 编辑 values-production.yaml 替换所有占位符，然后：
helm install lobehub ./helm -f helm/values-production.yaml
```

## 配置参数

### 全局配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `global.imagePullPolicy` | 镜像拉取策略 | `IfNotPresent` |
| `global.imagePullSecrets` | 私有仓库凭证 | `[]` |

### LobeHub 应用

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `lobe.replicaCount` | 副本数 | `1` |
| `lobe.image.repository` | 镜像仓库 | `lobehub/lobehub` |
| `lobe.image.tag` | 镜像标签 | `latest` |
| `lobe.service.type` | Service 类型 | `ClusterIP` |
| `lobe.service.port` | Service 端口 | `3210` |
| `lobe.ingress.enabled` | 是否启用 Ingress | `false` |
| `lobe.appUrl` | 应用外部访问 URL | `http://localhost:3210` |

### 密钥

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `secrets.keyVaultsSecret` | 密钥保险库密钥（**必填**） | `""` |
| `secrets.authSecret` | 认证密钥（**必填**） | `""` |
| `secrets.jwksKey` | JWKS RSA 密钥 | `""` |

### PostgreSQL

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `postgresql.enabled` | 是否启用内置 PostgreSQL | `true` |
| `postgresql.database` | 数据库名 | `lobechat` |
| `postgresql.password` | 数据库密码（**必填**） | `""` |
| `postgresql.persistence.size` | 存储大小 | `20Gi` |

### Redis

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `redis.enabled` | 是否启用内置 Redis | `true` |
| `redis.persistence.size` | 存储大小 | `5Gi` |

### RustFS

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `rustfs.enabled` | 是否启用 RustFS | `true` |
| `rustfs.accessKey` | 访问密钥 | `admin` |
| `rustfs.secretKey` | 密钥（**必填**） | `""` |
| `rustfs.bucket` | 存储桶名 | `lobe` |
| `rustfs.s3Endpoint` | S3 外部端点 | `""` |
| `rustfs.persistence.size` | 存储大小 | `20Gi` |

### SearXNG

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `searxng.enabled` | 是否启用 SearXNG | `true` |
| `searxng.useDefaultSettings` | 使用默认配置 | `true` |

## 目录结构

```
helm/
├── Chart.yaml                        # Chart 元数据
├── values.yaml                       # 默认配置
├── values-production.yaml            # 生产环境示例配置
├── .helmignore                       # 打包忽略规则
├── README.md                         # 本文件
└── templates/
    ├── _helpers.tpl                  # 模板辅助函数
    ├── NOTES.txt                     # 安装提示
    ├── configmap.yaml                # ConfigMap（应用配置 + bucket 策略）
    ├── secret.yaml                   # Secret（密钥、密码、凭证）
    ├── lobe-deployment.yaml          # LobeHub Deployment + Service
    ├── ingress.yaml                  # Ingress（可选）
    ├── postgresql.yaml               # PostgreSQL StatefulSet + Service
    ├── redis.yaml                    # Redis StatefulSet + Service
    ├── rustfs.yaml                   # RustFS StatefulSet + Service
    ├── rustfs-init-job.yaml          # RustFS 初始化 Job（Helm Hook）
    └── searxng.yaml                  # SearXNG Deployment + Service
```

## 注意事项

- PostgreSQL、Redis、RustFS 使用 **StatefulSet** 以确保数据持久化
- RustFS 初始化使用 **Helm Hook** (`post-install,post-upgrade`)，自动创建 bucket
- 生产环境强烈建议配置 **Ingress + TLS**
- 如需上传图片到会话，`rustfs.s3Endpoint` 必须配置为浏览器可访问的地址
- SearXNG 配置文件较大（~66KB），建议在 ConfigMap 中使用自定义精简配置

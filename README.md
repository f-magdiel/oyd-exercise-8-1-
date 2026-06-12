# Ejercicio 8.1 — Módulo IAM de Mínimo Privilegio

**Curso:** Optimizaciones y Desempeño — Automatización de Despliegue en la Nube
**Sesión:** 8 — 11 de junio de 2026
**Terraform:** `>= 1.6` | **Proveedor AWS:** `~> 5.0` | **Región:** `us-east-1`

---

## Descripción General

Este repositorio implementa un **módulo IAM de mínimo privilegio** en Terraform para un servicio de procesamiento de medios en AWS. El objetivo es reemplazar políticas IAM con comodines inseguros (`*`) por permisos granulares y específicos por componente, siguiendo el principio de mínimo privilegio.

El servicio cuenta con dos componentes:

| Componente | Runtime | Permisos Otorgados |
|---|---|---|
| `app-server` | EC2 | `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket` sobre el bucket de medios |
| `job-processor` | Lambda | `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes` sobre la cola + `s3:PutObject` restringido al prefijo `/results/*` |

> Ninguna política contiene `Action: "*"` ni `Resource: "*"`.

---

## Arquitectura

```
Cuenta AWS
│
├── S3 Bucket: nexus-media-dev-media
│   ├── app-server      → Lectura / Escritura / Eliminación / Listado (bucket completo)
│   └── job-processor   → Solo PutObject en el prefijo /results/*
│
├── SQS Queue: nexus-media-dev-jobs
│   └── job-processor   → ReceiveMessage / DeleteMessage / GetQueueAttributes
│
├── IAM Role: nexus-media-dev-app-server-role
│   ├── Principal de confianza: ec2.amazonaws.com
│   ├── Política: nexus-media-dev-app-server-policy
│   └── Instance Profile: nexus-media-dev-app-server-profile
│
└── IAM Role: nexus-media-dev-job-processor-role
    ├── Principal de confianza: lambda.amazonaws.com
    └── Política: nexus-media-dev-job-processor-policy
```

---

## Estructura del Repositorio

```
oyd-exercise-8-1/
├── main.tf                          # Raíz: S3, SQS, llamada al módulo y outputs
├── variables.tf                     # Variables raíz: project, environment
├── versions.tf                      # Restricción de versión de Terraform
├── dev.tfvars                       # Valores de variables para entorno dev
├── .gitignore                       # Excluye .terraform/, estado, archivos sensibles
├── infra/
│   └── modules/
│       └── iam/
│           ├── main.tf              # Roles, políticas, adjuntos, instance profile
│           ├── variables.tf         # Inputs del módulo: project, environment, ARNs
│           └── outputs.tf           # Outputs: ARNs de roles y nombre del profile
└── evidence/
    └── apply.txt                    # Salida capturada del terraform apply
```

---

## Prerrequisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.6`
- Credenciales AWS configuradas con permisos para gestionar recursos de **IAM**, **S3** y **SQS**
- AWS CLI (opcional, para verificar credenciales)

Verificar el entorno:

```bash
terraform version
aws sts get-caller-identity
```

---

## Uso

### 1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd oyd-exercise-8-1
```

### 2. Formatear

```bash
terraform fmt -recursive
```

### 3. Inicializar

```bash
terraform init
```

### 4. Validar

```bash
terraform validate
```

Resultado esperado:
```
Success! The configuration is valid.
```

### 5. Planificar

```bash
terraform plan -var-file=dev.tfvars
```

Resumen esperado:
```
Plan: 9 to add, 0 to change, 0 to destroy.
```

### 6. Aplicar

```bash
terraform apply -var-file=dev.tfvars -auto-approve | tee evidence/apply.txt
```

Resultado esperado: **9 recursos** creados (2 de infraestructura base + 7 IAM).

### 7. Destruir (limpieza)

```bash
terraform destroy -var-file=dev.tfvars -auto-approve
```

---

## Evidencia — Ejecución de Comandos

La siguiente captura muestra la ejecución exitosa de `terraform init`, `terraform validate` y `terraform plan`:

![Ejecución de terraform init, validate y plan](./Screenshot%202026-06-11%20at%2019-09-17.png)

1. **`terraform validate`** — Configuración válida sin errores
2. **`terraform plan`** — Terraform detecta 9 recursos a crear
3. **Plan detallado** — Se muestra la creación del bucket S3 y los recursos IAM

---

## Módulo: `infra/modules/iam`

### Variables de Entrada

| Variable | Tipo | Descripción |
|---|---|---|
| `project` | `string` | Nombre del proyecto, usado como prefijo en los recursos |
| `environment` | `string` | Entorno de despliegue (`dev`, `staging`, `prod`) |
| `s3_bucket_arn` | `string` | ARN del bucket S3 de medios |
| `sqs_queue_arn` | `string` | ARN de la cola SQS de trabajos |

### Recursos Creados

| Recurso | Nombre en AWS |
|---|---|
| `aws_iam_role.app_server` | `{project}-{env}-app-server-role` |
| `aws_iam_policy.app_server` | `{project}-{env}-app-server-policy` |
| `aws_iam_role_policy_attachment.app_server` | — |
| `aws_iam_instance_profile.app_server` | `{project}-{env}-app-server-profile` |
| `aws_iam_role.job_processor` | `{project}-{env}-job-processor-role` |
| `aws_iam_policy.job_processor` | `{project}-{env}-job-processor-policy` |
| `aws_iam_role_policy_attachment.job_processor` | — |

### Outputs

| Output | Descripción |
|---|---|
| `app_server_role_arn` | ARN del rol IAM para la instancia EC2 |
| `app_server_instance_profile_name` | Nombre del instance profile para EC2 |
| `job_processor_role_arn` | ARN del rol IAM para la función Lambda |

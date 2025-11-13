# Railway 배포 가이드

이 문서는 Laravel 애플리케이션을 Railway에 배포하는 방법을 설명합니다.

## 사전 준비사항

1. [Railway](https://railway.app) 계정 생성
2. GitHub 저장소에 코드 푸시 (또는 Railway CLI 사용)

## 배포 단계

### 1. Railway 프로젝트 생성

1. Railway 대시보드에서 "New Project" 클릭
2. "Deploy from GitHub repo" 선택
3. 저장소 선택 및 연결

### 2. 환경 변수 설정

Railway 대시보드의 Variables 탭에서 다음 환경 변수들을 설정하세요:

#### 필수 환경 변수

```
APP_NAME=Laravel
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://your-app-name.up.railway.app

DB_CONNECTION=pgsql
DB_HOST=your-db-host.railway.app
DB_PORT=5432
DB_DATABASE=railway
DB_USERNAME=postgres
DB_PASSWORD=your-db-password

LOG_CHANNEL=stack
LOG_LEVEL=error
```

#### APP_KEY 생성 방법

로컬에서 다음 명령어를 실행하여 APP_KEY를 생성하세요:

```bash
php artisan key:generate --show
```

생성된 키를 `APP_KEY` 환경 변수에 설정하세요.

### 3. 데이터베이스 설정

1. Railway 프로젝트에서 "New" → "Database" → "Add PostgreSQL" 선택
2. 생성된 데이터베이스의 연결 정보를 환경 변수에 설정
3. Railway는 자동으로 `DATABASE_URL` 환경 변수를 제공합니다

#### DATABASE_URL 사용 (권장)

Railway가 제공하는 `DATABASE_URL`을 사용하려면 `config/database.php`를 수정하거나, 다음 환경 변수들을 개별적으로 설정할 수 있습니다:

```
DB_HOST=containers-us-west-xxx.railway.app
DB_PORT=5432
DB_DATABASE=railway
DB_USERNAME=postgres
DB_PASSWORD=your-password
```

### 4. 마이그레이션 실행

배포 후 Railway 대시보드의 Deployments 탭에서 "View Logs"를 클릭하여 로그를 확인하고, 필요시 다음 명령어를 실행하세요:

```bash
php artisan migrate --force
```

또는 Railway CLI를 사용하여:

```bash
railway run php artisan migrate --force
```

### 5. 스토리지 링크

파일 업로드 기능을 사용하는 경우, 다음 명령어를 실행하세요:

```bash
railway run php artisan storage:link
```

## 배포 후 확인사항

1. 애플리케이션이 정상적으로 실행되는지 확인
2. 데이터베이스 연결 확인
3. 파일 업로드 기능 테스트 (storage 링크 확인)
4. 로그 확인 (Railway 대시보드의 Logs 탭)

## 문제 해결

### 빌드 실패

- `composer.json`의 PHP 버전 요구사항 확인
- `vendor` 폴더가 `.gitignore`에 포함되어 있는지 확인

### 데이터베이스 연결 오류

- 환경 변수가 올바르게 설정되었는지 확인
- PostgreSQL 데이터베이스가 생성되었는지 확인
- `DB_CONNECTION=pgsql`로 설정되어 있는지 확인

### 500 에러

- `APP_KEY`가 설정되어 있는지 확인
- `APP_DEBUG=true`로 설정하여 상세 오류 확인
- 로그 파일 확인 (Railway 대시보드의 Logs 탭)

## 추가 리소스

- [Railway 문서](https://docs.railway.app)
- [Laravel 배포 문서](https://laravel.com/docs/5.7/deployment)


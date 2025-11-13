# Railway MySQL 연결 및 Import 가이드

## 단계별 실행 방법

### 1단계: Railway 프로젝트 연결

터미널에서 다음 명령어를 실행하세요:

```bash
cd /Users/lomyun/Desktop/cine
railway link
```

프롬프트가 나타나면:
- Workspace 선택: `yuonodf's Projects`
- Project 선택: `cine` 프로젝트 선택

### 2단계: MySQL 서비스 추가

프로젝트가 연결되면 다음 명령어로 MySQL을 추가합니다:

```bash
railway add --database mysql --service mysql
```

또는 Railway 대시보드에서:
1. Railway 대시보드 접속
2. 프로젝트 선택
3. "New" → "Database" → "Add MySQL" 클릭

### 3단계: 환경 변수 확인 및 설정

MySQL이 추가되면 자동으로 다음 환경 변수가 생성됩니다:
- `MYSQLHOST`
- `MYSQLPORT`
- `MYSQLDATABASE`
- `MYSQLUSER`
- `MYSQLPASSWORD`

Laravel에서 사용할 수 있도록 다음 명령어로 환경 변수를 설정하세요:

```bash
railway variables set DB_CONNECTION=mysql
railway variables set DB_HOST=\$MYSQLHOST
railway variables set DB_PORT=\$MYSQLPORT
railway variables set DB_DATABASE=\$MYSQLDATABASE
railway variables set DB_USERNAME=\$MYSQLUSER
railway variables set DB_PASSWORD=\$MYSQLPASSWORD
```

### 4단계: SQL 파일 Import

MySQL이 준비되면 다음 명령어로 import합니다:

```bash
railway connect mysql < database/import.sql
```

또는 MySQL 클라이언트를 사용하여:

```bash
# 환경 변수 로드
railway shell

# MySQL 클라이언트로 import
mysql -h $MYSQLHOST -P $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE < database/import.sql
```

### 5단계: 데이터 확인

```bash
railway connect mysql
```

MySQL 프롬프트에서:
```sql
SHOW TABLES;
SELECT COUNT(*) FROM posts;
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM users;
EXIT;
```

## 자동화 스크립트 사용

위의 모든 단계를 자동으로 실행하는 스크립트:

```bash
./setup-mysql.sh
```

**주의:** 프로젝트가 연결되어 있어야 합니다. 먼저 `railway link`를 실행하세요.


# Railway MySQL 데이터베이스 설정 가이드

## 1. Railway에서 MySQL 데이터베이스 추가

1. Railway 대시보드에서 프로젝트 선택
2. "New" 버튼 클릭
3. "Database" → "Add MySQL" 선택
4. MySQL 서비스가 생성되면 연결 정보 확인

## 2. 환경 변수 설정

Railway 대시보드의 Variables 탭에서 다음 환경 변수들을 설정하세요:

```
DB_CONNECTION=mysql
DB_HOST=containers-us-west-xxx.railway.app
DB_PORT=3306
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=your-mysql-password
```

**참고:** Railway는 자동으로 `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLHOST`, `MYSQLPORT` 환경 변수를 제공합니다.

## 3. SQL 파일 Import 방법

### 방법 1: Railway CLI 사용 (권장)

```bash
# Railway CLI 설치 (아직 안 했다면)
npm i -g @railway/cli

# Railway 로그인
railway login

# 프로젝트 연결
railway link

# MySQL에 연결하여 SQL 파일 import
railway connect mysql < database/import.sql
```

### 방법 2: MySQL 클라이언트 직접 연결

1. Railway MySQL 서비스의 "Connect" 탭에서 연결 정보 확인
2. 로컬에서 MySQL 클라이언트로 연결:

```bash
mysql -h containers-us-west-xxx.railway.app \
      -P 3306 \
      -u root \
      -p \
      railway < database/import.sql
```

### 방법 3: Railway 대시보드에서 직접 실행

1. Railway MySQL 서비스의 "Data" 탭으로 이동
2. "Query" 탭에서 SQL 파일 내용을 복사하여 실행
3. 또는 "Import" 기능 사용 (있는 경우)

## 4. 데이터베이스 이름 변경

SQL 파일의 데이터베이스 이름이 `cidkpqwz_cinecar`인데, Railway는 기본적으로 `railway`라는 이름을 사용합니다.

**옵션 1:** SQL 파일에서 데이터베이스 이름을 `railway`로 변경
**옵션 2:** Railway에서 데이터베이스 이름을 `cidkpqwz_cinecar`로 변경 (환경 변수에서)

## 5. Import 후 확인

```bash
# Railway CLI로 MySQL에 연결
railway connect mysql

# 또는 직접 연결
mysql -h $MYSQLHOST -P $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE

# 테이블 확인
SHOW TABLES;

# 데이터 확인
SELECT COUNT(*) FROM posts;
SELECT COUNT(*) FROM categories;
```

## 6. Laravel 마이그레이션 실행 (선택사항)

기존 데이터를 import한 후, Laravel 마이그레이션을 실행할 필요는 없습니다. 
하지만 마이그레이션 테이블을 확인하려면:

```bash
railway run php artisan migrate:status
```

## 문제 해결

### 연결 오류
- 방화벽 설정 확인
- Railway MySQL 서비스가 실행 중인지 확인
- 환경 변수가 올바르게 설정되었는지 확인

### Import 오류
- SQL 파일의 인코딩 확인 (UTF-8)
- 데이터베이스 이름이 올바른지 확인
- 권한 문제 확인


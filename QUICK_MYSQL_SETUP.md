# 빠른 MySQL 설정 가이드

## 방법 1: Railway 대시보드 사용 (가장 쉬움)

### 1. MySQL 추가
1. https://railway.app 접속
2. `adorable-amazement` 프로젝트 선택
3. "New" 버튼 클릭
4. "Database" → "Add MySQL" 선택
5. MySQL 서비스 생성 대기 (약 1-2분)

### 2. 환경 변수 설정
1. MySQL 서비스 클릭
2. "Variables" 탭에서 연결 정보 확인
3. 웹 서비스(애플리케이션) 선택
4. "Variables" 탭에서 다음 추가:
   ```
   DB_CONNECTION=mysql
   DB_HOST=${{MySQL.MYSQLHOST}}
   DB_PORT=${{MySQL.MYSQLPORT}}
   DB_DATABASE=${{MySQL.MYSQLDATABASE}}
   DB_USERNAME=${{MySQL.MYSQLUSER}}
   DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
   ```

### 3. SQL Import
터미널에서:
```bash
cd /Users/lomyun/Desktop/cine
railway link  # 프로젝트 선택: adorable-amazement
railway connect mysql < database/import.sql
```

## 방법 2: Railway CLI 사용

### 1. 프로젝트 연결
```bash
cd /Users/lomyun/Desktop/cine
railway link
# 프롬프트에서:
# - Workspace: yuonodf's Projects
# - Project: adorable-amazement
```

### 2. MySQL 추가
```bash
railway add --database mysql --service mysql
```

### 3. 환경 변수 설정
```bash
railway variables set DB_CONNECTION=mysql
railway variables set DB_HOST=\$MYSQLHOST
railway variables set DB_PORT=\$MYSQLPORT
railway variables set DB_DATABASE=\$MYSQLDATABASE
railway variables set DB_USERNAME=\$MYSQLUSER
railway variables set DB_PASSWORD=\$MYSQLPASSWORD
```

### 4. SQL Import
```bash
railway connect mysql < database/import.sql
```

## Import 확인

```bash
railway connect mysql
```

MySQL 프롬프트에서:
```sql
SHOW TABLES;
SELECT COUNT(*) FROM posts;
SELECT COUNT(*) FROM categories;
EXIT;
```


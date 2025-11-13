#!/bin/bash

# Railway MySQL Import 스크립트
# 사용법: ./railway-mysql-import.sh

echo "=========================================="
echo "Railway MySQL 데이터베이스 Import"
echo "=========================================="
echo ""

# Railway 프로젝트 확인
if ! railway status &>/dev/null; then
    echo "❌ Railway 프로젝트가 연결되지 않았습니다."
    echo "다음 명령어로 프로젝트를 연결하세요:"
    echo "  railway link"
    exit 1
fi

echo "✅ Railway 프로젝트 연결 확인됨"
echo ""

# MySQL 서비스 확인
echo "MySQL 서비스를 확인하는 중..."
MYSQL_SERVICE=$(railway service list 2>/dev/null | grep -i mysql || echo "")

if [ -z "$MYSQL_SERVICE" ]; then
    echo "⚠️  MySQL 서비스가 발견되지 않았습니다."
    echo ""
    echo "Railway 대시보드에서 MySQL을 추가하세요:"
    echo "1. Railway 대시보드 → 프로젝트 선택"
    echo "2. 'New' → 'Database' → 'Add MySQL' 선택"
    echo "3. MySQL 서비스 생성 대기"
    echo ""
    echo "MySQL 서비스를 추가한 후 이 스크립트를 다시 실행하세요."
    exit 1
fi

echo "✅ MySQL 서비스 발견됨"
echo ""

# 환경 변수 확인
echo "MySQL 연결 정보 확인 중..."
if [ -z "$MYSQLHOST" ] || [ -z "$MYSQLDATABASE" ] || [ -z "$MYSQLUSER" ] || [ -z "$MYSQLPASSWORD" ]; then
    echo "⚠️  MySQL 환경 변수가 설정되지 않았습니다."
    echo "Railway 대시보드에서 MySQL 서비스의 Variables 탭을 확인하세요."
    echo ""
    echo "필요한 환경 변수:"
    echo "  - MYSQLHOST"
    echo "  - MYSQLPORT (기본값: 3306)"
    echo "  - MYSQLDATABASE"
    echo "  - MYSQLUSER"
    echo "  - MYSQLPASSWORD"
    exit 1
fi

echo "✅ MySQL 연결 정보 확인됨"
echo "  Host: $MYSQLHOST"
echo "  Port: ${MYSQLPORT:-3306}"
echo "  Database: $MYSQLDATABASE"
echo "  User: $MYSQLUSER"
echo ""

# SQL 파일 확인
if [ ! -f "database/import.sql" ]; then
    echo "❌ database/import.sql 파일을 찾을 수 없습니다."
    exit 1
fi

echo "✅ SQL 파일 확인됨: database/import.sql"
echo ""

# MySQL 클라이언트 확인
if ! command -v mysql &> /dev/null; then
    echo "⚠️  MySQL 클라이언트가 설치되지 않았습니다."
    echo ""
    echo "macOS에서 설치:"
    echo "  brew install mysql-client"
    echo ""
    echo "또는 Railway CLI를 사용하여 import:"
    echo "  railway connect mysql < database/import.sql"
    exit 1
fi

echo "✅ MySQL 클라이언트 확인됨"
echo ""

# Import 실행
echo "데이터베이스 import를 시작합니다..."
echo ""

mysql -h "$MYSQLHOST" \
      -P "${MYSQLPORT:-3306}" \
      -u "$MYSQLUSER" \
      -p"$MYSQLPASSWORD" \
      "$MYSQLDATABASE" \
      < database/import.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 데이터베이스 import가 성공적으로 완료되었습니다!"
    echo "=========================================="
    echo ""
    echo "다음 명령어로 데이터를 확인할 수 있습니다:"
    echo "  railway connect mysql"
    echo "  mysql> SHOW TABLES;"
    echo "  mysql> SELECT COUNT(*) FROM posts;"
else
    echo ""
    echo "=========================================="
    echo "❌ 데이터베이스 import 중 오류가 발생했습니다."
    echo "=========================================="
    exit 1
fi


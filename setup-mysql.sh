#!/bin/bash

# Railway MySQL 설정 및 Import 스크립트

echo "=========================================="
echo "Railway MySQL 설정 및 Import"
echo "=========================================="
echo ""

# 1. 프로젝트 연결 확인
echo "1. Railway 프로젝트 연결 확인 중..."
if ! railway status &>/dev/null; then
    echo "⚠️  Railway 프로젝트가 연결되지 않았습니다."
    echo ""
    echo "다음 명령어로 프로젝트를 연결하세요:"
    echo "  railway link"
    echo ""
    echo "또는 Railway 대시보드에서:"
    echo "1. https://railway.app 접속"
    echo "2. 프로젝트 선택 또는 새 프로젝트 생성"
    echo "3. 'Settings' → 'Connect GitHub' (이미 연결되어 있다면 생략)"
    echo ""
    read -p "프로젝트를 연결한 후 Enter를 누르세요..."
fi

echo "✅ 프로젝트 연결 확인됨"
echo ""

# 2. MySQL 서비스 확인 또는 추가
echo "2. MySQL 서비스 확인 중..."
MYSQL_EXISTS=$(railway service list 2>/dev/null | grep -i mysql || echo "")

if [ -z "$MYSQL_EXISTS" ]; then
    echo "⚠️  MySQL 서비스가 없습니다. 추가합니다..."
    echo ""
    
    # MySQL 추가
    railway add --database mysql --service mysql
    
    if [ $? -eq 0 ]; then
        echo "✅ MySQL 서비스가 추가되었습니다!"
        echo ""
        echo "MySQL 서비스가 준비될 때까지 잠시 기다려주세요..."
        sleep 5
    else
        echo "❌ MySQL 서비스 추가에 실패했습니다."
        echo ""
        echo "Railway 대시보드에서 수동으로 추가하세요:"
        echo "1. 'New' → 'Database' → 'Add MySQL'"
        exit 1
    fi
else
    echo "✅ MySQL 서비스가 이미 존재합니다."
fi

echo ""

# 3. 환경 변수 확인
echo "3. MySQL 연결 정보 확인 중..."
railway variables

echo ""
echo "MySQL 환경 변수가 설정되었는지 확인하세요:"
echo "  - MYSQLHOST"
echo "  - MYSQLPORT"
echo "  - MYSQLDATABASE"
echo "  - MYSQLUSER"
echo "  - MYSQLPASSWORD"
echo ""

# 4. Laravel 환경 변수 설정
echo "4. Laravel 환경 변수 설정 중..."
railway variables set DB_CONNECTION=mysql
railway variables set DB_HOST=\$MYSQLHOST
railway variables set DB_PORT=\$MYSQLPORT
railway variables set DB_DATABASE=\$MYSQLDATABASE
railway variables set DB_USERNAME=\$MYSQLUSER
railway variables set DB_PASSWORD=\$MYSQLPASSWORD

echo "✅ Laravel 환경 변수 설정 완료"
echo ""

# 5. SQL 파일 import
echo "5. SQL 파일 import 중..."
echo ""

if [ ! -f "database/import.sql" ]; then
    echo "❌ database/import.sql 파일을 찾을 수 없습니다."
    exit 1
fi

echo "Railway MySQL에 연결하여 import를 시작합니다..."
echo ""

# Railway connect를 사용하여 import
railway connect mysql < database/import.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 데이터베이스 import가 성공적으로 완료되었습니다!"
    echo "=========================================="
    echo ""
    echo "데이터 확인:"
    echo "  railway connect mysql"
    echo "  mysql> SHOW TABLES;"
    echo "  mysql> SELECT COUNT(*) FROM posts;"
else
    echo ""
    echo "⚠️  Railway connect로 import에 실패했습니다."
    echo ""
    echo "대안: MySQL 클라이언트를 사용하여 직접 import:"
    echo "  mysql -h \$MYSQLHOST -P \$MYSQLPORT -u \$MYSQLUSER -p\$MYSQLPASSWORD \$MYSQLDATABASE < database/import.sql"
fi


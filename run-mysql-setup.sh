#!/bin/bash

# adorable-amazement 프로젝트에 MySQL 추가 및 Import 스크립트

echo "=========================================="
echo "Railway MySQL 설정 및 Import"
echo "프로젝트: adorable-amazement"
echo "=========================================="
echo ""

# 프로젝트 연결 확인
echo "1. 프로젝트 연결 확인 중..."
if ! railway status &>/dev/null; then
    echo "⚠️  프로젝트가 연결되지 않았습니다."
    echo ""
    echo "다음 명령어로 프로젝트를 연결하세요:"
    echo "  railway link"
    echo ""
    echo "프롬프트에서 'adorable-amazement' 프로젝트를 선택하세요."
    echo ""
    read -p "프로젝트를 연결한 후 Enter를 누르세요..."
fi

echo "✅ 프로젝트 연결 확인됨"
PROJECT_NAME=$(railway status 2>/dev/null | grep -i "project" || echo "")
echo "  $PROJECT_NAME"
echo ""

# MySQL 서비스 확인
echo "2. MySQL 서비스 확인 중..."
MYSQL_EXISTS=$(railway service list 2>/dev/null | grep -i mysql || echo "")

if [ -z "$MYSQL_EXISTS" ]; then
    echo "⚠️  MySQL 서비스가 없습니다. 추가합니다..."
    echo ""
    
    railway add --database mysql --service mysql
    
    if [ $? -eq 0 ]; then
        echo "✅ MySQL 서비스가 추가되었습니다!"
        echo ""
        echo "MySQL 서비스가 준비될 때까지 10초 대기 중..."
        sleep 10
    else
        echo "❌ MySQL 서비스 추가에 실패했습니다."
        echo ""
        echo "Railway 대시보드에서 수동으로 추가하세요:"
        echo "1. adorable-amazement 프로젝트 선택"
        echo "2. 'New' → 'Database' → 'Add MySQL'"
        exit 1
    fi
else
    echo "✅ MySQL 서비스가 이미 존재합니다."
fi

echo ""

# 환경 변수 설정
echo "3. Laravel 환경 변수 설정 중..."
railway variables set DB_CONNECTION=mysql 2>/dev/null
railway variables set DB_HOST=\$MYSQLHOST 2>/dev/null
railway variables set DB_PORT=\$MYSQLPORT 2>/dev/null
railway variables set DB_DATABASE=\$MYSQLDATABASE 2>/dev/null
railway variables set DB_USERNAME=\$MYSQLUSER 2>/dev/null
railway variables set DB_PASSWORD=\$MYSQLPASSWORD 2>/dev/null

echo "✅ 환경 변수 설정 완료"
echo ""

# 환경 변수 확인
echo "4. MySQL 연결 정보 확인 중..."
railway variables | grep MYSQL || echo "환경 변수를 확인하세요"
echo ""

# SQL 파일 확인
if [ ! -f "database/import.sql" ]; then
    echo "❌ database/import.sql 파일을 찾을 수 없습니다."
    exit 1
fi

echo "✅ SQL 파일 확인됨: database/import.sql"
echo ""

# Import 실행
echo "5. SQL 파일 import 시작..."
echo ""

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
    echo "  mysql> SELECT COUNT(*) FROM categories;"
    echo "  mysql> EXIT;"
else
    echo ""
    echo "⚠️  Railway connect로 import에 실패했습니다."
    echo ""
    echo "대안: Railway shell을 사용하여 import:"
    echo "  railway shell"
    echo "  mysql -h \$MYSQLHOST -P \$MYSQLPORT -u \$MYSQLUSER -p\$MYSQLPASSWORD \$MYSQLDATABASE < database/import.sql"
fi


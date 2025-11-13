#!/bin/bash

# Railway MySQL Import 스크립트

echo "=========================================="
echo "Railway MySQL 데이터베이스 Import"
echo "=========================================="
echo ""

# 프로젝트 연결 확인
if ! railway status &>/dev/null; then
    echo "❌ Railway 프로젝트가 연결되지 않았습니다."
    echo "다음 명령어로 프로젝트를 연결하세요:"
    echo "  railway link"
    exit 1
fi

echo "✅ 프로젝트 연결 확인됨"
echo ""

# MySQL 서비스 확인
echo "MySQL 서비스 확인 중..."
MYSQL_CHECK=$(railway connect mysql --help 2>&1 | head -1)

if echo "$MYSQL_CHECK" | grep -q "not found"; then
    echo "⚠️  MySQL 서비스가 발견되지 않았습니다."
    echo ""
    echo "Railway 대시보드에서 MySQL을 추가하세요:"
    echo "1. https://railway.app 접속"
    echo "2. adorable-amazement 프로젝트 선택"
    echo "3. 'New' → 'Database' → 'Add MySQL' 선택"
    echo "4. MySQL 서비스 생성 대기 (약 1-2분)"
    echo ""
    echo "MySQL 서비스를 추가한 후 이 스크립트를 다시 실행하세요."
    exit 1
fi

echo "✅ MySQL 서비스 발견됨"
echo ""

# SQL 파일 확인
if [ ! -f "database/import.sql" ]; then
    echo "❌ database/import.sql 파일을 찾을 수 없습니다."
    exit 1
fi

echo "✅ SQL 파일 확인됨: database/import.sql"
echo ""

# Import 실행
echo "데이터베이스 import를 시작합니다..."
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
    echo "⚠️  Import 중 오류가 발생했습니다."
    echo ""
    echo "다시 시도하거나 Railway 대시보드에서 MySQL 서비스 상태를 확인하세요."
    exit 1
fi


#!/bin/bash

# Railway MySQL 데이터베이스 import 스크립트
# 사용법: railway connect mysql < database/import.sql

echo "MySQL 데이터베이스 import를 시작합니다..."

# Railway 환경 변수 확인
if [ -z "$MYSQLHOST" ]; then
    echo "경고: MYSQLHOST 환경 변수가 설정되지 않았습니다."
    echo "Railway 대시보드에서 MySQL 서비스를 추가하고 환경 변수를 확인하세요."
    exit 1
fi

# MySQL 클라이언트로 직접 연결하여 import
mysql -h "$MYSQLHOST" \
      -P "${MYSQLPORT:-3306}" \
      -u "$MYSQLUSER" \
      -p"$MYSQLPASSWORD" \
      "$MYSQLDATABASE" < database/import.sql

if [ $? -eq 0 ]; then
    echo "✅ 데이터베이스 import가 완료되었습니다!"
else
    echo "❌ 데이터베이스 import 중 오류가 발생했습니다."
    exit 1
fi


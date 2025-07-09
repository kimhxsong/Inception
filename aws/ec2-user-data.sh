#!/bin/bash
# Amazon Linux 2023 사용자 데이터 스크립트
# Docker, Docker Compose, Git, Make 설치 및 kimhxsong 프로젝트 자동 실행

# 로그 파일 설정
LOG_FILE="/var/log/user-data-script.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "=== 사용자 데이터 스크립트 시작: $(date) ==="

# 함수 정의: 에러 처리
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# 함수 정의: 상태 확인
check_status() {
    if [ $? -eq 0 ]; then
        echo "SUCCESS: $1"
    else
        handle_error "$1 실패"
    fi
}

# 시스템 업데이트
echo "1. 시스템 패키지 업데이트 중..."
yum update -y
check_status "시스템 업데이트"

# 필수 패키지 설치
echo "2. 필수 패키지 설치 중..."
yum install -y git make
check_status "필수 패키지 설치"

# Docker 및 Docker Compose 설치
echo "5. Docker 및 Docker Compose 설치 중..."
yum install -y docker
sudo mkdir -p /usr/local/lib/docker/cli-plugins/
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
check_status "Docker 및 Docker Compose 설치"

# Docker 서비스 시작 및 활성화
echo "7. Docker 서비스 구성 중..."
systemctl start docker
systemctl enable docker
check_status "Docker 서비스 시작"

# ec2-user를 docker 그룹에 추가
echo "8. 사용자 권한 설정 중..."
usermod -a -G docker ec2-user
check_status "사용자 권한 설정"

# Docker 소켓 권한 설정 (임시)
chmod 666 /var/run/docker.sock
check_status "Docker 소켓 권한 설정"

# 프로젝트 클론 및 실행 (ec2-user 컨텍스트에서)
echo "9. 프로젝트 클론 및 실행 중..."
sudo -u ec2-user bash <<'EOF'
# 홈 디렉토리로 이동
cd /home/ec2-user

# GitHub 저장소 클론
echo "GitHub 저장소 클론 중..."
git clone https://github.com/kimhxsong/Inception.git
if [ $? -ne 0 ]; then
    echo "ERROR: GitHub 저장소 클론 실패"
    exit 1
fi

# 프로젝트 디렉토리로 이동
cd Inception

# Docker 서비스 완전 시작 대기
echo "Docker 서비스 완전 시작 대기 중..."
sleep 5

# Docker 상태 확인
docker --version
docker compose version

# make up 실행
echo "make up 실행 중..."
make up
if [ $? -ne 0 ]; then
    echo "ERROR: make up 실행 실패"
    exit 1
fi

echo "프로젝트 실행 완료!"
EOF

check_status "프로젝트 클론 및 실행"

# 최종 설치 확인
echo "10. 최종 설치 확인 중..."
echo "Docker 버전: $(docker --version)"
echo "Docker Compose 버전: $(docker compose version)"
echo "Git 버전: $(git --version)"
echo "Make 버전: $(make --version)"

# 서비스 상태 확인
echo "11. 서비스 상태 확인:"
systemctl status docker --no-pager

# 실행 중인 컨테이너 확인
echo "12. 실행 중인 컨테이너:"
docker ps

# 완료 메시지
echo "=== 사용자 데이터 스크립트 완료: $(date) ==="
echo "프로젝트가 성공적으로 배포되었습니다!"
echo "로그 파일 위치: $LOG_FILE"

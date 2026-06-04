# 1단계: 경량 고성능 파이썬 공식 런타임 베이스 베이킹
FROM python:3.11-slim

# 2단계: 컨테이너 내부 환경의 작업 디렉터리 고정
WORKDIR /app

# 3단계: 가상 서버 내부 최적화 시간 동기화 (KST 세팅)
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 4단계: 라이브러리 명세서 먼저 선 복사 (도커 빌드 레이어 캐싱 적용으로 빌드 속도 최적화)
COPY requirements.txt .

# 5단계: 불필요한 캐시 찌꺼기 없이 순수 파이썬 패키지 고속 설치
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 6단계: 내 소스코드 전체 및 86만 개 DUR 공공데이터 CSV 파일 폴더 전체 복사
COPY . .

# 7단계: FastAPI 기본 인프라 웹 채널 포트 8000번 가상 개방
EXPOSE 8000

# 8단계: 컨테이너 부팅 시 외부 수용이 가능한 uvicorn 프로덕션 모드 가동 엔진 명령 설정
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
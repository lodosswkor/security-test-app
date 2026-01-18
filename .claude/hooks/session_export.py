"""
Claude Code SessionEnd Hook
세션 종료 시 transcript를 HTML로 변환하여 저장
"""
import sys
import json
import subprocess
from pathlib import Path
from datetime import datetime


def main():
    # stdin에서 SessionEnd 데이터 읽기
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = input_data.get('session_id', 'unknown')
    transcript_path = input_data.get('transcript_path')
    cwd = input_data.get('cwd', '')
    reason = input_data.get('reason', '')  # 'exit', 'interrupt' 등

    # transcript 파일 확인
    if not transcript_path:
        sys.exit(0)
    
    transcript_file = Path(transcript_path)
    if not transcript_file.exists():
        sys.exit(0)

    # 출력 디렉토리 설정
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    output_base = Path(cwd) / 'transcripts'
    output_dir = output_base / f'{timestamp}_{session_id[:8]}'
    output_dir.mkdir(parents=True, exist_ok=True)

    # claude-code-transcripts로 HTML 변환
    try:
        subprocess.run(
            [
                'claude-code-transcripts', 'json',
                str(transcript_file),
                '-o', str(output_dir),
                '--json'  # 원본 JSONL도 함께 저장
            ],
            check=True,
            capture_output=True,
            timeout=60
        )
    except subprocess.CalledProcessError:
        sys.exit(0)
    except subprocess.TimeoutExpired:
        sys.exit(0)
    except FileNotFoundError:
        # claude-code-transcripts가 설치되지 않은 경우
        sys.exit(0)

    sys.exit(0)


if __name__ == '__main__':
    main()
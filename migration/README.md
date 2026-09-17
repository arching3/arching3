# 새 배포판 migration 설정

이 디렉터리에는 Git에 올려도 되는 사용자 설정만 보관합니다. SSH 개인키,
GitHub CLI 인증 토큰, ngrok 인증 토큰, Codex 인증 정보는 의도적으로 포함하지
않습니다.

## 복원 순서

1. 새 배포판에서 이 저장소를 clone합니다.
2. Git 사용자 설정을 적용합니다.

   ```bash
   cp migration/.gitconfig ~/.gitconfig
   ```

3. SSH host 별칭을 적용하고, 개인키는 암호화된 개인 백업으로 별도 복원하거나
   새 키를 생성합니다.

   ```bash
   install -d -m 700 ~/.ssh
   install -m 600 migration/ssh/config ~/.ssh/config
   # 기존 개인키를 별도로 복원했다면:
   chmod 600 ~/.ssh/id_rsa
   ssh -T git@arching3.github.com
   ```

4. Bash와 Vim 개발 환경 및 Vim 플러그인을 한 번에 적용합니다.

   ```bash
   ./scripts/install_dev_env.sh --yes
   ```

이 스크립트는 기존 `~/.bashrc`, `~/.vimrc`를 먼저 백업한 뒤 관리 블록만
갱신합니다. Vundle, everforest, 그리고 `dotfiles/vimrc_plugins.vim`에 선언된
플러그인도 설치합니다.

## 새 배포판에서 다시 설정할 항목

- `gh auth login`으로 GitHub CLI 인증
- `ngrok config add-authtoken ...`으로 ngrok 인증
- Codex 로그인
- 필요 패키지, NVM/Node, Rust, Python virtual environment

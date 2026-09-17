# 새 배포판 migration 설정

이 디렉터리에는 Git에 올려도 되는 사용자 설정만 보관합니다. SSH 개인키,
GitHub CLI 인증 토큰, ngrok 인증 토큰, Codex 인증 정보는 의도적으로 포함하지
않습니다.

## 복원 순서

1. 새 배포판에서 이 저장소를 clone합니다.
2. 기존 개인키를 암호화된 개인 백업으로 별도 복원하거나, 새 키를 생성합니다.
   개인키는 이 저장소에 넣지 않습니다.
3. Git 전역 사용자 정보와 SSH host 설정을 안전하게 적용합니다.

   ```bash
   ./scripts/install_migration_configs.sh --yes
   ```

   이 스크립트는 기존 `~/.gitconfig`, `~/.ssh/config`를 백업하고,
   Git의 전역 `user.name`과 `user.email`을 설정합니다. 또한 기존 SSH host는
   보존한 채 `arching3.github.com` 블록만 추가 또는 갱신합니다.

4. GitHub 인증을 확인합니다.

   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa
   ./scripts/install_migration_configs.sh --yes --test-github
   ```

5. Bash와 Vim 개발 환경 및 Vim 플러그인을 한 번에 적용합니다.

   ```bash
   ./scripts/install_dev_env.sh --yes
   ```

이 스크립트는 기존 `~/.bashrc`, `~/.vimrc`를 먼저 백업한 뒤 관리 블록만
갱신합니다. Vundle, everforest, 그리고 `dotfiles/vimrc_plugins.vim`에 선언된
플러그인도 설치합니다.

## GitHub에 SSH 공개키를 다시 등록해야 하나요?

- **기존 개인키와 같은 키를 복원하는 경우:** 다시 등록할 필요가 없습니다.
  GitHub에는 이미 그 공개키가 등록되어 있으므로 개인키의 권한만 `600`으로
  맞추고 `ssh-add`하면 됩니다.
- **새 키를 생성하는 경우:** 새 공개키(`.pub`)를 GitHub의 **Settings → SSH and
  GPG keys → New SSH key**에 등록해야 합니다. 기존 키는 새 배포판의 인증이
  확인된 후에만 필요에 따라 삭제하세요.

## 새 배포판에서 다시 설정할 항목

- `gh auth login`으로 GitHub CLI 인증
- `ngrok config add-authtoken ...`으로 ngrok 인증
- Codex 로그인
- 필요 패키지, NVM/Node, Rust, Python virtual environment

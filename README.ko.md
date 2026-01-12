[ ![🇬🇧 English](https://img.shields.io/badge/%F0%9F%87%AC%F0%9F%87%A7-English-blue) ](README.md) [ ![🇫🇷 Français](https://img.shields.io/badge/%F0%9F%87%AB%F0%9F%87%B7-Fran%C3%A7ais-blue) ](README.fr.md) [ ![🇪🇸 Español](https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8-Espa%C3%B1ol-blue) ](README.es.md) [ ![🇩🇪 Deutsch](https://img.shields.io/badge/%F0%9F%87%A9%F0%9F%87%AA-Deutsch-blue) ](README.de.md) [ ![🇮🇹 Italiano](https://img.shields.io/badge/%F0%9F%87%AE%F0%9F%87%B9-Italiano-blue) ](README.it.md) [ ![🇷🇺 Русский](https://img.shields.io/badge/%F0%9F%87%B7%F0%9F%87%BA-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-blue) ](README.ru.md) [ ![🇯🇵 日本語](https://img.shields.io/badge/%F0%9F%87%AF%F0%9F%87%B5-%E6%97%A5%E6%9C%AC%E8%AA%9E-blue) ](README.ja.md) [ ![🇨🇳 中文](https://img.shields.io/badge/%F0%9F%87%A8%F0%9F%87%B3-%E4%B8%AD%E6%96%87-blue) ](README.zh.md)

# vesktopCustomCommands (VCC) 소개
VCC는 Vesktop에 음소거 및 귀먹게 하기 전역 단축키를 추가할 수 있는 시스템입니다. 이는 Vesktop 팀이 더 나은 솔루션을 찾을 때까지 현재 Vesktop의 전역 단축키 부족에 대한 임시 솔루션입니다.
기본적으로 시스템의 사용자 정의 전역 단축키에서 호출할 수 있는 일련의 스크립트(`mute.sh` 및 `deafen.sh`)로, Vesktop에서 자신을 음소거 및 귀먹게 하며, Vencord 메인 파일에 사용자 정의 Javascript 코드를 주입하여 Vesktop에서 이러한 작업을 트리거합니다.

# 시스템의 단축키 구성
`~/.vesktopCustomCommands/` 폴더에 있는 `mute.sh` 및 `deafen.sh` 스크립트를 호출하려면 시스템에서 사용자 정의 전역 단축키를 구성해야 합니다.
```plaintext
~/.vesktopCustomCommands/mute.sh
```
```plaintext
~/.vesktopCustomCommands/deafen.sh
```

---

# 설치

## 자동 설치
터미널에서 이 명령을 실행하고 지침을 따르세요:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/install.sh)"
```
참고: `~/.vesktopCustomCommands/.config`에 구성 파일이 이미 있는 경우 설치 프로그램은 이를 보존하고 필요한 경우에만 `vencord_path` 항목을 업데이트합니다.

### 선택 사항: 자동 재패치

설치 중에 VCC 패치가 Vencord 메인 파일에 여전히 존재하는지 주기적으로 확인하고 제거된 경우(예: Vencord/Vesktop 업데이트 또는 재설정 후) 다시 적용하는 자동 재패치 시스템을 활성화할 수 있습니다.

- 왜 필요한가요? Vesktop/Vencord 업데이트 또는 특정 시작 시나리오로 인해 메인 파일이 원래 상태로 복원되어 VCC 주입이 제거될 수 있습니다. 자동 재패치는 수동 개입 없이 단축키가 계속 작동하도록 보장합니다.
- 설정은 `~/.vesktopCustomCommands/.config`에 저장됩니다:
  - `auto_repatch="true|false"` (기본값: `false`)
  - `auto_restart="true|false"` (기본값: `false`) – 활성화된 경우 재패치 후 Vesktop이 자동으로 재시작됩니다. 나중에 다음 명령으로 전환할 수 있습니다.
  - `autorepatch_interval="30s|1m|3m"` (기본값: `30s`) – 확인 간격.
  - `auto_repatch`가 활성화되면 선택한 간격으로 사용자 `systemd` 타이머가 실행됩니다.
  - 자동 재패치 활성화:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorepatch.sh)"
  ```
  - 자동 재패치 비활성화:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorepatch.sh)"
  ```

  - 자동 재시작 활성화(재패치 후):
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autorestart.sh)"
  ```
  - 자동 재시작 비활성화:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autorestart.sh)"
  ```


수동 구성: `~/.vesktopCustomCommands/.config`를 편집하고 `auto_repatch` 및 `auto_restart`를 설정합니다. `autorepatch_interval`을 `"30s"`, `"1m"` 또는 `"3m"`으로 설정할 수도 있습니다. 수동으로 비활성화하면 다음 설치 실행 시 타이머가 중지되거나 위의 비활성화 스크립트를 실행하세요.

### 선택 사항: 자동 업데이트

GitHub에서 새 버전을 사용할 수 있는지 정기적으로 확인하고 필요한 파일(Vencord용 사용자 정의 코드 및 `mute.sh` 및 `deafen.sh`와 같은 로컬 스크립트)을 업데이트하는 자동 업데이트 시스템을 활성화할 수 있습니다.

- `~/.vesktopCustomCommands/.config`의 설정:
  - `auto_update="true|false"` (기본값: `false`)
  - `auto_update_interval` (기본값: `15m`) – 자동 재패치가 활성화된 경우 `autorepatch_interval`로 실행되고, 자동 업데이트만 활성화된 경우 `auto_update_interval`로 실행됩니다.
- 자동 업데이트 활성화:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/enable_autoupdate.sh)"
  ```
- 자동 업데이트 비활성화:
  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/dist/vesktopCustomCommands/disable_autoupdate.sh)"
  ```

## 수동 설치
1. 저장소에서 `dist` 폴더 또는 해당 내용을 다운로드합니다.
2. `dist`는 두 부분으로 나뉩니다:
    - `vencord` 폴더에는 Vencord 메인 파일에 주입할 파일이 포함되어 있습니다.
    - `vesktopCustomCommands` 폴더에는 음소거/귀먹게 하기용 스크립트와 `.config` 파일이 포함되어 있습니다.
3. Vencord 메인 파일(일반적으로 `~/.config/Vencord/dist/vencordDesktopMain.js`에 있음)의 백업을 만들 수 있습니다(`cp ~/.config/Vencord/dist/vencordDesktopMain.js ~/.config/Vencord/dist/vencordDesktopMain.js.bak`). 나중에 복원하려면 파일을 삭제하고 Vesktop을 시작하여 다시 만들 수 있습니다.
4. `vencordDesktopMain_sample.js`의 내용을 Vencord 메인 파일(일반적으로 `~/.config/Vencord/dist/vencordDesktopMain.js`에 있음)에 주입합니다:
    - 파일 끝에 있는 `//# sourceURL=` 줄 바로 앞에 `vencordDesktopMain_sample.js`의 전체 내용을 삽입합니다.
5. Vencord 경로(일반적으로 `~/.config/Vencord/dist/`에 있음)에 `vesktopCustomCommands` 디렉토리를 만들고 그 안에 `customCode.js` 파일을 넣습니다.
6. `~/.vesktopCustomCommands` 디렉토리를 만들고 그 안에 `mute.sh` 및 `deafen.sh` 파일을 넣습니다.
7. `mute.sh` 및 `deafen.sh` 스크립트에 권한 추가:
    ```bash
    chmod +x ~/.vesktopCustomCommands/mute.sh
    chmod +x ~/.vesktopCustomCommands/deafen.sh
    ```
8. `.config` 파일을 `~/.vesktopCustomCommands`에 넣고 필요한 경우 Vencord 경로로 `vencord_path` 변수를 업데이트합니다.
9. Vesktop을 재시작하여 변경 사항을 적용합니다.
10. `~/.vesktopCustomCommands/` 폴더에 있는 `mute.sh` 및 `deafen.sh` 스크립트를 호출하도록 시스템에서 사용자 정의 전역 단축키를 구성합니다.
    - 자신을 음소거하는 `mute.sh`. `~/.vesktopCustomCommands/mute.sh`
    - 자신을 귀먹게 하는 `deafen.sh`. `~/.vesktopCustomCommands/deafen.sh`
11. 음소거 및 귀먹게 하기를 위한 새로운 전역 단축키를 즐기세요!

---

# 제거

## 자동 제거

터미널에서 이 명령을 실행하고 지침을 따르세요:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NitramO-YT/vesktopCustomCommands/refs/heads/main/uninstall.sh)"
```
제거하는 동안 설정(`~/.vesktopCustomCommands/.config`)을 포함한 모든 것을 제거할지 물어봅니다.
- "y"라고 답하세요: 모든 파일과 설정이 제거됩니다.
- "n"이라고 답하세요: 프로그램 파일만 제거되고 `.config`는 보존됩니다.

설정이 제거되면 자동 재패치 서비스/타이머 및 도우미 스크립트도 제거됩니다. 자동 제거를 거부하는 경우 아래의 수동 제거 단계를 따르세요(동일한 지침이 스크립트에서도 표시됨).

## 수동 제거

1. `~/.vesktopCustomCommands/` 폴더에 있는 `mute.sh` 및 `deafen.sh` 스크립트를 호출하는 시스템의 사용자 정의 전역 단축키를 제거합니다.
2. `~/.vesktopCustomCommands`의 `.config` 파일을 제거합니다.
3. `~/.vesktopCustomCommands` 폴더를 제거합니다.
4. Vencord 경로 `~/.config/Vencord/dist/vesktopCustomCommands/`의 `customCode.js` 파일을 제거합니다.
5. Vencord 경로 `~/.config/Vencord/dist/`의 `vesktopCustomCommands` 폴더를 제거합니다.
6. Vencord 메인 파일(일반적으로 `~/.config/Vencord/dist/vencordDesktopMain.js`에 있음)에 주입된 코드를 제거하거나 만든 백업으로 바꿉니다(있는 경우). (파일을 삭제하고 Vesktop을 시작하여 다시 만들 수도 있습니다).
7. Vesktop을 재시작하여 변경 사항을 적용합니다.

---

# 문제 및 개선 사항

문제가 있거나 개선 제안이 있으면 issue를 열어주세요!

# 기여

이 시스템이 완벽하지 않고 모든 표준과 의미론을 준수하지 않았다는 것을 알고 있습니다. 그래서 이 시스템을 개선하는 데 도움을 주고 싶은 분들을 기대하고 있습니다. issue와 pull request가 열려 있으며 모든 건설적인 비판을 환영합니다!

---

# 이 프로젝트의 주요 목표 설명

저는 X11에서 KDE Neon을 사용하는 사용자였고 Discord는 전반적으로 잘 작동했습니다. 최근 Wayland에서 KDE Neon으로 전환했는데 Discord에 많은 문제가 있었고, 특히 화면 공유가 불가능했습니다. Discord 문제를 해결하려고 찾던 중 Vesktop과 그에 따른 Vencord를 발견했고, 이것이 해결한 모든 문제와 X11에서 이미 겪고 있던 일부 문제(예: 화면 공유 중 소리를 공유할 가능성이 전혀 없음)를 발견했습니다. 설치했는데 모든 것이 완벽했지만 한 가지 작은 세부 사항이 있었습니다: 전역 키보드 단축키 지원 부족입니다. 유일한 가능성은 창이 활성 상태일 때만 작동하는 기본 Discord 단축키(`Ctrl + Shift + M` 및 `Ctrl + Shift + D`)였습니다. 그래서 Vesktop에서 단축키를 찾기 시작했고 문제는 알려져 있지만 해결책은 아직 찾지 못했다는 것을 읽을 수 있었습니다. 특히 Wayland에서 전역 키보드 단축키를 만들려는 개발자의 삶을 복잡하게 만드는 것 같습니다. 그래서 포기하려고 생각했지만 모든 좋은 개발자처럼 포기할 수 없었기 때문에 해결책을 생각했고 임시적이지만 견고한 해결책을 찾았습니다. 불안정한 시스템을 원하지 않았기 때문에 시스템을 최대한 간단하고 기능적으로 만들려고 했습니다. Vesktop을 포크하고 해결책을 찾거나 내 것을 통합하기 위해 열심히 일할 수도 있었지만, 더 이상 그런 야망과 시간이 없고, 또한 Vesktop에서 전역 키보드 단축키를 원하는 사람들을 위한 대체 저장소를 만드는 것이 진지하거나 건강하다고 생각하지 않습니다. 그래서 공식 위에 추가되는 모드 또는 애드온으로 생각하는 것이 이상적이라고 생각했습니다. 결국 Vencord 자체처럼, 관심 있는 사람들이 필요한 경우 설치할 수 있도록 하는 것입니다. Vesktop이 전역 키보드 단축키에 대한 해결책을 찾을 때까지 이것으로 충분할 것입니다!

---

감사합니다 :)



<!-- Made with ❤️ by NitramO -->

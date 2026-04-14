# Actions

타이니셀 재사용 워크플로우 저장소.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
# 📖 Table of Contents

- [Workflow](#workflow)
- [배포](#%EB%B0%B0%ED%8F%AC)
  - [Google Play](#google-play)
  - [App Store (testflight)](#app-store-testflight)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Workflow

워크플로우 파일은 `.github/workflows/`에 작성하면 된다.

기본적으로 main 브랜치에 생성하는것을 권장한다.

저장소 페이지의 Actions탭에 가면 main의 워크플로우만 보이기도 하고 관리면에서도 심플해진다.

**workflow-dispatch**

워크플로우를 실행하는 가장 간단한 방법.

```yaml
on:
  workflow_dispatch:
```

on에 workflow_dispatch를 작성해두면 Actions탭에서 수동으로 실행 가능하다.

**self-hosted runners**

빌드머신으로 맥미니 한 대가 세팅되어 있음.

`self-hosted`, `macOS` 두 태그로 특정해서 사용.

```yaml
jobs:
  build:
    runs-on:
      - self-hosted
      - macOS
```

## 배포

계정 범위에서 공유되는 값들은 배포 워크플로우에서 세팅되어 있어 앱 개별로 필요한 값만 세팅해주면 된다.

`Repository -> Settings -> Actions secrets and variables -> Actions -> Variables -> Repository variables`

### Google Play

`TODO`

### App Store (testflight)

> [!WARNING]
> 프로비저닝 프로파일 관련 파이프라인이 작성되어 않아 첫 빌드 시 문제가 발생할 수 있음.  
> `error: exportArchive No profiles for 'com.company.app' were found`  
> 이 에러가 나오면 Xcode로 배포.

`<apple-account>-deploy-testflight`

> [See workflow](https://github.com/TinycellCorp/Actions/blob/main/.github/workflows/superlee-deploy-testflight.yml)

| Variables | Description | 
| --- | --- |
| `PACKAGE_NAME_IOS` | `AppStoreConnect -> App -> App Information -> Bundle ID` |
| `APP_INFO_APPLE_ID` | `AppStoreConnect -> App -> App Information -> Apple ID` |

```yaml
name: Deploy testflight

on:
  workflow_dispatch:
    inputs:
      slack-channel-id:
        type: string
        required: false
        description: default ('0_build' channel)
      skip-testflight:
        type: boolean
        required: false
        default: false
        
jobs:
  deploy:
    uses: TinycellCorp/Actions/.github/workflows/superlee-deploy-testflight.yml@main
    with:
      app-identifier: ${{ vars.PACKAGE_NAME_IOS }}
      app-info-apple-id: ${{ vars.APP_INFO_APPLE_ID }}
      slack-channel-id: ${{ inputs.slack-channel-id }}
      skip-testflight: ${{ inputs.skip-testflight }}
    secrets: inherit
```

| Inputs | Description | 
| --- | --- |
| `slack-channel-id` | `배포 알림을 보낼 타이니셀 슬랙 채널아이디. 봇이 초대되어 있어야 한다.` |
| `skip-testflight` | `배포 프로세스에서 테스트 플라이트 업로드를 스킵` |

## iOS 코드 서명 인증서

### 인증서 갱신 시 주의사항 (macOS Sequoia)

macOS 15(Sequoia)부터 Xcode에서 생성한 인증서의 private key 접근 제어가 강화되었다.

Xcode의 Manage Certificates에서 인증서를 생성하면 **해당 Xcode 앱 경로만 접근 허용**으로 설정되어, 다른 버전의 Xcode나 `codesign` 바이너리가 키에 접근할 수 없다.

인증서 갱신 후 CI 빌드가 `errSecInternalComponent`로 실패하면 아래 3가지 방법 중 하나로 해결:

| 방법 | 설명 | 비고 |
|------|------|------|
| CI Xcode 버전으로 생성 | 인증서를 CI에서 사용하는 Xcode 버전으로 생성 | Xcode 버전 변경 시 재생성 필요 |
| 키 접근 모든 앱 허용 | Keychain Access에서 private key > 접근 제어 > "모든 응용 프로그램이 접근 가능"으로 변경 | 인증서 갱신 시 다시 설정 필요 |
| partition list 설정 | `security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k <password> login.keychain-db` | Fastfile `before_all`에 포함되어 자동 처리 |

> [!NOTE]
> 현재 Fastfile의 `before_all`에 partition list 설정이 포함되어 있어 자동으로 처리된다.
> 기존 정상 인증서에는 영향 없음.

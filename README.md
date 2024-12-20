# Actions

타이니셀 재사용 워크플로우 저장소.

## Workflow

워크플로우 파일은 `.github/workflows/`에 작성하면 된다.

기본적으로 main 브랜치에 생성하는것을 권장한다.

저장소 페이지의 Actions탭에 가면 main의 워크플로우만 보이기도 하고 관리면에서도 심플해진다.

## self-hosted runners

빌드머신으로 맥미니 한 대를 세팅되어 있음.

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

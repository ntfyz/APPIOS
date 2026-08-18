# BasicButtonApp

Ứng dụng iOS native viết bằng **Swift + SwiftUI**, được build hoàn toàn tự động bằng **GitHub Actions** trên macOS runner.

Bạn code trên **Windows** (VS Code), push lên GitHub, GitHub Actions chạy Xcode trên máy Mac ảo, build và trả về file `.ipa` để tải về.

```
Windows (VS Code) --> push --> GitHub --> GitHub Actions (macOS + Xcode) --> build --> IPA --> tải từ Artifacts
```

Không cần: máy Mac, Hackintosh, macOS VM, Xcode trên Windows, React Native, Flutter, Expo.

---

## Cấu trúc repo

```
BasicButtonApp/
├── .github/
│   └── workflows/
│       └── build-ios.yml          # Workflow build IPA
│
├── BasicButtonApp/
│   ├── BasicButtonApp.swift       # Entry point (@main)
│   ├── ContentView.swift          # Màn hình chính với button "Press Me"
│   ├── Info.plist                 # Thông tin app
│   └── Assets.xcassets/
│       ├── Contents.json
│       ├── AccentColor.colorset/
│       │   └── Contents.json
│       └── AppIcon.appiconset/
│           ├── Contents.json
│           └── AppIcon.png        # Icon 1024x1024 (đã tạo sẵn)
│
├── BasicButtonApp.xcodeproj/
│   ├── project.pbxproj            # Xcode project (đã cấu hình đầy đủ)
│   └── xcshareddata/
│       └── xcschemes/
│           └── BasicButtonApp.xcscheme   # Scheme được share cho CI
│
├── ExportOptions.plist            # Cấu hình export IPA
├── .gitignore
└── README.md
```

Thông số chính:

| Thông số | Giá trị |
|---|---|
| Project / Target / Scheme | `BasicButtonApp` |
| Bundle Identifier | `com.example.basicbuttonapp` |
| Deployment Target | iOS 16.0 |
| Version / Build | `1.0` / `1` |
| Configuration | `Release` |

---

## 1. Chạy project (từ Windows)

### Bước 1 - Tạo repo trên GitHub

1. Vào https://github.com → New repository
2. Tên repo ví dụ: `BasicButtonApp` (Public hoặc Private đều được)
3. **Không** chọn "Add a README" hay ".gitignore" (repo trống)
4. Create repository

### Bước 2 - Push code từ Windows

Mở PowerShell trong thư mục chứa project (thư mục có chứa `BasicButtonApp.xcodeproj`):

```powershell
git init
git add .
git commit -m "update"
git branch -M main
git remote add origin https://github.com/<TEN_USER>/<TEN_REPO>.git
git push -u origin main
```

Thay `<TEN_USER>` và `<TEN_REPO>` bằng tên của bạn. Lần đầu push GitHub sẽ hỏi đăng nhập (dùng Personal Access Token thay cho password).

### Bước 3 - Setup GitHub Secrets

Xem mục **5. GitHub Secrets** bên dưới. Không có secrets thì signing sẽ fail.

### Bước 4 - Chạy build

Vào GitHub → tab **Actions** → **Build iOS IPA** → **Run workflow** → chạy.
Hoặc workflow tự chạy mỗi khi bạn `git push` lên nhánh `main`.

---

## 2. Những gì cần từ Apple Developer

Để ký (sign) IPA cài lên iPhone thật, bạn cần 4 thứ:

### a) Apple Developer account

- Tài khoản miễn phí (Apple ID thường): đủ để tạo Development certificate + profile cho 1 thiết bị.
- Tài khoản trả phí ($99/năm): cần nếu muốn Ad Hoc nhiều thiết bị hoặc đăng App Store.

### b) Team ID

- Vào https://developer.apple.com/account → nhìn mục **Membership Details** → **Team ID**
- Là chuỗi 10 ký tự, ví dụ: `A1B2C3D4E5`
- Lưu vào secret `APPLE_TEAM_ID`

### c) Certificate (.p12)

- Loại: **Apple Development** (nếu dùng method `development`) hoặc **Apple Distribution** (nếu dùng `ad-hoc` / `app-store-connect`)
- Tạo tại https://developer.apple.com/account/resources/certificates
- Export thành file `.p12` (xem mục 3)

### d) Provisioning profile (.mobileprovision)

- Loại phải khớp với certificate và method:
  - `development`: **iOS App Development** profile
  - `ad-hoc`: **Ad Hoc** profile
  - `app-store-connect`: **App Store** profile
- **Bundle Identifier phải là `com.example.basicbuttonapp`** (hoặc wildcard `com.example.*`)
- Với profile `development` / `ad-hoc`: phải thêm UDID của iPhone của bạn vào profile
- Tạo tại https://developer.apple.com/account/resources/profiles

> Lưu ý: Certificate và profile phải được tạo bởi **cùng một Team ID**.

---

## 3. Export file .p12

File `.p12` chứa private key + certificate. Cách export (cần một máy Mac hoặc máy có Keychain Access - chỉ cần làm **1 lần**):

1. Trên máy Mac, mở **Keychain Access** (Spotlight tìm `Keychain Access`)
2. Ở góc trái chọn **My Certificates**
3. Tìm certificate `Apple Development: <Tên của bạn> (XXXX)`
4. Click chuột phải → **Export "Apple Development: ..."**
5. Định dạng: **Personal Information Exchange (.p12)**
6. Đặt password cho file `.p12` → nhớ password này, nó chính là `IOS_CERTIFICATE_PASSWORD`

> Không ai được nhìn thấy password này ngoài bạn. Nó chỉ được lưu trong GitHub Secrets.

---

## 4. Encode base64 trên Windows PowerShell

GitHub Secrets không nhận file nhị phân, nên ta encode `.p12` và `.mobileprovision` thành chuỗi base64.

Đặt 2 file vào một thư mục, mở PowerShell trong thư mục đó:

### Certificate (.p12)

```powershell
[Convert]::ToBase64String(
    [IO.File]::ReadAllBytes("certificate.p12")
) | Set-Content -NoNewline certificate_base64.txt
```

### Provisioning profile (.mobileprovision)

```powershell
[Convert]::ToBase64String(
    [IO.File]::ReadAllBytes("profile.mobileprovision")
) | Set-Content -NoNewline profile_base64.txt
```

### Kiểm tra

```powershell
Get-Item certificate_base64.txt, profile_base64.txt | Select-Object Name, Length
```

Mỗi file là **một dòng duy nhất** (không xuống dòng). Mở file bằng Notepad, bôi đen **toàn bộ** nội dung để copy.

> `-NoNewline` quan trọng: nếu thiếu, file sẽ có thêm ký tự xuống dòng gây lỗi decode trên CI.
>
> Sau khi lưu secret xong, **xóa 2 file** này khỏi máy hoặc để ngoài thư mục repo (`.gitignore` đã chặn chúng).

---

## 5. GitHub Secrets

Vào:

```
GitHub repo
→ Settings
→ Secrets and variables
→ Actions
→ New repository secret
```

Thêm **5 secrets** sau:

| Secret | Nội dung | Ví dụ |
|---|---|---|
| `IOS_CERTIFICATE_BASE64` | Toàn bộ nội dung `certificate_base64.txt` | `MIIJ9QIBAzCC...` (rất dài) |
| `IOS_CERTIFICATE_PASSWORD` | Password của file `.p12` (mục 3) | `myP12Password123` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Toàn bộ nội dung `profile_base64.txt` | `MIIXXQYJ...` (rất dài) |
| `KEYCHAIN_PASSWORD` | Password tự nghĩ để tạo keychain tạm trên CI | `ciKeychain2026!` |
| `APPLE_TEAM_ID` | Team ID của bạn | `A1B2C3D4E5` |

Quy trình với từng secret: **New repository secret** → dán Name → dán Value → **Add secret**.

> Secret không bao giờ xuất hiện trong log build - GitHub tự che chúng.
> Không bao giờ commit `.p12`, `.mobileprovision`, password vào repo.

---

## 6. Chạy build

1. Vào GitHub repo của bạn
2. Tab **Actions**
3. Chọn workflow **Build iOS IPA**
4. Bấm **Run workflow** → **Run workflow** (để trống branch = default `main`)
5. Chờ ~5-10 phút. Workflow chạy: checkout → xem Xcode version → check scheme → tạo keychain → import cert → cài profile → archive → export → upload artifact

Nếu muốn build tự động mỗi lần push, chỉ cần `git push` lên nhánh `main` - workflow tự chạy.

---

## 7. Download IPA

1. Vào tab **Actions** → chọn run mới nhất
2. Kéo xuống mục **Artifacts**
3. Bấm **BasicButtonApp-IPA** → tải file zip về
4. Giải nén → bên trong là `BasicButtonApp.ipa`

### Cài lên iPhone

- iPhone phải nằm trong danh sách device của provisioning profile
- Cách cài:
  - **macOS**: Finder → iPhone → kéo thả `.ipa`
  - **Windows**: dùng Sideloadly, AltStore, hoặc Apple Configurator 2 (Apple Configurator chỉ chạy trên Mac/Windows bản mới có hỗ trợ Windows)
- Cài xong vào Settings → General → VPN & Device Management → tin tưởng developer của bạn

---

## 8. Đổi method export (development / ad-hoc / app-store-connect)

Mặc định `ExportOptions.plist` dùng:

```xml
<key>method</key>
<string>development</string>
```

Để đổi, sửa `ExportOptions.plist` trong repo (đổi dòng `<string>development</string>`):

| method | Certificate cần | Profile cần | Cài được lên iPhone? | Ghi chú |
|---|---|---|---|---|
| `development` (mặc định) | Apple Development | iOS App Development | Có (device trong profile) | Dễ nhất, không cần tài khoản trả phí |
| `ad-hoc` | Apple Distribution | Ad Hoc | Có (device trong profile) | Không cần review, tối đa 100 device |
| `app-store-connect` | Apple Distribution | App Store | Không trực tiếp | Để upload lên App Store Connect |

Ngoài ra cần đổi certificate + profile tương ứng (xem mục 2). Cách tạo cert/profile đổi cũng giống, chỉ khác loại ở trang Apple Developer.

> Khuyến nghị: bắt đầu với `development` - dễ nhất, miễn phí, cài được ngay lên iPhone của bạn.

---

## 9. Các lỗi signing phổ biến và cách sửa

| Lỗi | Nguyên nhân | Cách sửa |
|---|---|---|
| `No profiles for 'com.example.basicbuttonapp' were found` | Chưa cài profile hoặc profile không khớp bundle id | Kiểm tra secret `IOS_PROVISIONING_PROFILE_BASE64`; chắc chắn profile có bundle id `com.example.basicbuttonapp` |
| `User interaction is not allowed` | Keychain tạm chưa được set đúng | Chắc chắn workflow chạy đủ 2 bước `set-key-partition-list` và `unlock-keychain` (đã có sẵn trong workflow) |
| `errSecInternalComponent` | Password keychain sai / keychain bị khóa | Kiểm tra `KEYCHAIN_PASSWORD` khớp giữa các bước |
| `A valid provisioning profile for this executable was not found` | Profile hết hạn hoặc device không có trong profile | Tạo lại profile, thêm UDID iPhone, cập nhật secret |
| `Code sign error: Certificate identity 'Apple Development: ...' appeared more than once` | Import nhiều lần cert trùng | Xóa keychain tạm (workflow đã cleanup) hoặc thử lại run |
| `Export failed: no applicable device found` | ExportOptions sai teamID hoặc cert không khớp profile | Chắc chắn `APPLE_TEAM_ID` đúng; cert và profile cùng loại (`development` ↔ Apple Development) |
| `A build can only be generated for a single destination` | Thiếu `-destination 'generic/platform=iOS'` khi archive | Không sửa workflow - đã có sẵn |
| `Signing certificate is not installed` (khi export) | Cert trong keychain không khớp profile | Import đúng cert tương ứng với profile vào secret |
| `Warning: App icon missing` | AppIcon.appiconset thiếu ảnh | Đã có sẵn `AppIcon.png` 1024x1024; chỉ cần khi bạn muốn đổi icon |
| Build fail nhưng log chung chung | Chạy lại workflow và mở từng step, nhìn step màu đỏ | Step nào đỏ là lỗi ở đó; log chi tiết đã in sẵn từng lệnh |

Mẹo: workflow in sẵn `xcodebuild -version` và `xcodebuild -list` ở 2 bước đầu - nếu project có vấn đề, lỗi sẽ hiện ngay ở đó trước cả phần signing.

---

## 10. Bảo mật

- Certificate, private key, password, profile: **chỉ** nằm trong GitHub Secrets
- `.gitignore` đã chặn `*.p12`, `*.mobileprovision`, `build/`, `certificate_base64.txt`, `profile_base64.txt`
- Workflow xóa file tạm ngay sau khi import và cleanup keychain sau khi build
- Không có secret nào bị in ra console

---

## 11. Kiểm tra nhanh trước khi push

```powershell
git status              # không được thấy *.p12 / *.mobileprovision
Get-ChildItem -Recurse -Include *.p12,*.mobileprovision
```

Nếu có file lạ nằm trong repo, xóa hoặc bỏ vào `.gitignore` trước khi `git push`.
# Joy Cards

Ứng dụng iOS native viết bằng **Swift + SwiftUI**, build hoàn toàn tự động bằng **GitHub Actions** trên macOS runner.

Bạn code trên **Windows** (VS Code), push lên GitHub, GitHub Actions chạy Xcode trên máy Mac ảo, build và trả về file `.ipa` để tải về.

```
Windows (VS Code) --> push --> GitHub --> GitHub Actions (macOS + Xcode) --> build --> IPA --> tải từ Artifacts
```

Không cần: máy Mac, Hackintosh, macOS VM, Xcode trên Windows, React Native, Flutter, Expo.

---

## App: Joy Cards

**Joy Cards** là một cuốn nhật ký kỷ niệm vui riêng tư. Mỗi kỷ niệm là một "card" gồm:

- Ảnh chụp (máy ảnh hoặc thư viện)
- Ghi chú ngắn (tối đa 200 ký tự)
- Cảm xúc (mood emoji)
- Tags (có thể thêm tag tùy chỉnh)
- Vị trí (tên + tọa độ, hoàn toàn local)

Các tính năng chính:

- **Home**: thẻ kỷ niệm ngẫu nhiên, kỷ niệm "cùng ngày năm ngoái" (on this day), streak liên tục
- **Memories**: lưới tất cả kỷ niệm, lọc theo mood / tag / tháng, xem chi tiết
- **Recap**: tổng kết theo tháng (số kỷ niệm, mood phổ biến, tags nổi bật)
- **Profile**: cài đặt nhắc nhở (notification lúc chọn giờ), đặt giờ recap, xóa dữ liệu

Dữ liệu lưu **hoàn toàn trên thiết bị** (SwiftData + thư mục Documents), không backend, không đăng ký tài khoản.

## Cấu trúc repo

```
JoyCards/
├── .github/
│   └── workflows/
│       ├── build-ios.yml            # Workflow build IPA (cần secrets, ký thật)
│       └── build-unsigned-ipa.yml   # Build IPA không ký (cài bằng Sideloadly, miễn phí)
│
├── JoyCards/                        # Source code app
│   ├── App/                         # Entry point (@main) + RootView (tab + onboarding)
│   ├── Models/                      # SwiftData model (JoyMemory)
│   ├── ViewModels/                  # Camera, CreateJoy, Memories, Recap
│   ├── Views/                       # Home, Memories, Recap, Profile, Onboarding, Capture
│   ├── Components/                  # JoyCardView, ShareCardView, MoodPicker, TagChip, ...
│   ├── Services/                    # ImageStore, LocationService, NotificationService
│   ├── Utilities/                   # Haptics, ShareSheet, StreakCalculator, UIImage+Normalized
│   ├── Info.plist                   # Thông tin app (kèm quyền camera/location/photos)
│   └── Assets.xcassets/
│       ├── AccentColor.colorset/
│       └── AppIcon.appiconset/      # Icon 1024x1024 (đã tạo sẵn)
│
├── JoyCards.xcodeproj/
│   ├── project.pbxproj              # Xcode project (đã cấu hình đầy đủ)
│   └── xcshareddata/
│       └── xcschemes/
│           └── JoyCards.xcscheme    # Scheme được share cho CI
│
├── ExportOptions.plist              # Cấu hình export IPA
├── .gitignore
└── README.md
```

Thông số chính:

| Thông số | Giá trị |
|---|---|
| Project / Target / Scheme | `JoyCards` |
| Bundle Identifier | `com.example.joycards` |
| Deployment Target | iOS 18.0 |
| Version / Build | `1.0` / `1` |
| Configuration | `Release` |

---

## 1. Chạy build (từ Windows)

### Bước 1 - Push code từ Windows

```powershell
git add .
git commit -m "update"
git push
```

### Bước 2 - Chọn cách build

**Cách A (miễn phí, không cần Apple Developer):** Vào GitHub → tab **Actions** → **Build Unsigned IPA** → **Run workflow**. Tải artifact `JoyCards-Unsigned-IPA` về, giải nén lấy file `.ipa`, cài bằng **Sideloadly** (xem mục 2).

**Cách B (cần secrets, ký thật):** Xem mục 3. Workflow **Build iOS IPA** sẽ chạy khi push nếu đã setup đủ secrets.

---

## 2. Cài IPA bằng Sideloadly (miễn phí, không cần Mac, không cần tài khoản $99)

1. Cài **iTunes** (Microsoft Store) và **iCloud** (mục quan trọng: Sideloadly cần `Apple Application Support` của iTunes/iCloud)
2. Tải **Sideloadly** tại https://sideloadly.io và cài đặt
3. Kết nối iPhone bằng dây cáp (USB), bấm **Trust** trên iPhone nếu được hỏi
4. Mở Sideloadly:
   - **IPA**: chọn file `JoyCards-unsigned.ipa`
   - **Apple ID**: nhập Apple ID của bạn (không cần tài khoản developer, Apple ID thường là được)
   - Bấm **Start**
5. Sideloadly sẽ tự ký bằng Apple ID và cài lên iPhone
6. Trên iPhone: **Settings → General → VPN & Device Management → Trust** developer profile của bạn
7. Mở app và dùng

> Lưu ý: app ký bằng Apple ID miễn phí có hiệu lực **7 ngày**. Hết hạn chỉ cần cài lại bằng Sideloadly (dữ liệu trong app vẫn giữ nguyên).

---

## 3. Build IPA ký thật (khi đã có tài khoản Apple Developer)

### a) Những gì cần từ Apple Developer

- **Apple Developer account** (miễn phí hoặc $99/năm)
- **Team ID** → secret `APPLE_TEAM_ID`
- **Certificate (.p12)** → secrets `IOS_CERTIFICATE_BASE64` + `IOS_CERTIFICATE_PASSWORD`
- **Provisioning profile (.mobileprovision)** → secret `IOS_PROVISIONING_PROFILE_BASE64`

> Bundle Identifier phải là `com.example.joycards` (hoặc wildcard `com.example.*`) trong profile.

### b) Export file .p12 (cần 1 lần, trên máy Mac)

1. Mở **Keychain Access** → **My Certificates**
2. Tìm `Apple Development: <Tên> (XXXX)` → chuột phải → **Export** → định dạng `.p12`
3. Đặt password → đây là `IOS_CERTIFICATE_PASSWORD`

### c) Encode base64 trên Windows PowerShell

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Set-Content -NoNewline certificate_base64.txt
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Set-Content -NoNewline profile_base64.txt
```

Mỗi file là **một dòng duy nhất** (dùng `-NoNewline`). Copy toàn bộ nội dung vào secret. Xóa file sau khi lưu xong.

### d) Thêm secrets

`Settings → Secrets and variables → Actions`:

| Secret | Nội dung |
|---|---|
| `IOS_CERTIFICATE_BASE64` | Nội dung `certificate_base64.txt` |
| `IOS_CERTIFICATE_PASSWORD` | Password file `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Nội dung `profile_base64.txt` |
| `KEYCHAIN_PASSWORD` | Password keychain tạm trên CI |
| `APPLE_TEAM_ID` | Team ID (10 ký tự) |

### e) Chạy build

Tab **Actions** → **Build iOS IPA** → **Run workflow** (hoặc tự chạy khi push lên `main`). Artifact `JoyCards-IPA` chứa IPA đã ký.

Cài lên iPhone: Finder (macOS) kéo thả `.ipa`, hoặc Sideloadly (Windows). Sau đó **Settings → VPN & Device Management → Trust**.

---

## 4. Bảo mật

- Certificate, private key, password, profile: **chỉ** nằm trong GitHub Secrets
- `.gitignore` đã chặn `*.p12`, `*.mobileprovision`, `build/`, `build-download/`, các file base64
- Không commit `.p12`, `.mobileprovision`, password vào repo

## 5. Kiểm tra nhanh trước khi push

```powershell
git status              # không được thấy *.p12 / *.mobileprovision
Get-ChildItem -Recurse -Include *.p12,*.mobileprovision
```

# Meme Check Giờ (iOS App) ⏰🔥

Ứng dụng iOS native viết bằng **Swift + SwiftUI**, đồng hồ thời gian thực siêu to, hệ thống meme và câu cà khịa (roast) phản ứng tự động theo từng khung giờ trong ngày trên iPhone.

Build hoàn toàn tự động bằng **GitHub Actions** trên macOS runner trả về file `.ipa`.

```
Windows (VS Code) --> push --> GitHub --> GitHub Actions (macOS + Xcode) --> build --> IPA --> tải từ Artifacts
```

Không cần: máy Mac, Hackintosh, macOS VM, Xcode trên Windows.

---

## Tính năng chính

- ⏰ **Live Big Clock**: Đồng hồ số lớn phong cách Neon Cyber / Sunset / OLED thời gian thực, cập nhật từng giây, đo % thời gian đã trôi qua trong ngày.
- 🎭 **Meme & Roasting Engine theo 8 khung giờ**:
  - **Sáng sớm (05:00 - 07:00)**: "Ai ép bạn dậy giờ này?"
  - **Chiến đấu sáng (07:00 - 11:30)**: Giả vờ bận rộn, canh giờ trưa.
  - **Giờ trưa (11:30 - 13:30)**: Ăn gì bây giờ? No bụng ngủ gật.
  - **Chiều gật gù (13:30 - 17:00)**: 1 phút dài bằng 1 năm, ngóng 5h chiều.
  - **Tan tầm (17:00 - 19:00)**: Kẹt xe bất lực, phóng về tự do.
  - **Tối chill (19:00 - 22:30)**: Lướt TikTok/phim bảo xem 5 phút nhưng trôi qua 2 tiếng.
  - **Nửa đêm (22:30 - 01:00)**: Bắt đầu suy nghĩ về cuộc đời và quá khứ.
  - **Giờ thiêng cú đêm (01:00 - 05:00)**: Cảnh báo mắt gấu trúc, sắp gặp tổ tiên!
- 🎲 **Nút "Check Giờ Nhanh"**: Đổi meme ngẫu nhiên theo khung giờ, kèm rung haptics giật mạnh, đếm số lần kiểm tra giờ trong ngày.
- 🎨 **Theme Switcher**: Đổi theme màu đồng hồ (Cyberpunk Neon, Sunset Chill, Mèo Bất Lực, Cú Đêm OLED, Trà Xanh).
- 📤 **Chia sẻ Card Meme**: Tạo status meme giờ nhanh chóng để chia sẻ lên Messenger, Story.

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

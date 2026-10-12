# Guest House App

Aplikasi Reservasi Kamar Guest House Berbasis Multi-Platform Menggunakan Framework Flutter

> Skripsi — Pengembangan Aplikasi Reservasi Kamar Guest House Berbasis Multi-Platform Menggunakan Framework Flutter

---

## Stack

| Layer            | Teknologi                             |
| ---------------- | ------------------------------------- |
| Frontend         | Flutter 3.x (Android)                 |
| State Management | Riverpod                              |
| Navigation       | GoRouter                              |
| Backend API      | PostgREST (auto REST dari PostgreSQL) |
| Database         | PostgreSQL 15                         |
| Auth             | JWT via PostgreSQL function           |
| GUI DB           | pgAdmin 4                             |
| Containerization | Docker Compose                        |

---

## Arsitektur

```
Flutter App (Android)
       ↕ HTTP/REST
  PostgREST :3000
       ↕ SQL
  PostgreSQL :5432
       ↕
  pgAdmin :5050 (development only)
```

---

## Struktur Folder

```
lib/
├── core/
│   ├── constants/     # AppConstants, AppRoutes
│   ├── errors/        # AppException hierarchy
│   ├── network/       # ApiClient (Dio), AppRouter (GoRouter)
│   ├── theme/         # AppTheme (colors, typography)
│   └── widgets/       # Shared widgets
└── features/
    ├── auth/          # Login, user entity, JWT
    ├── dashboard/     # Admin & Receptionist dashboard
    ├── rooms/         # Room entity, floor plan widget
    ├── reservations/  # Reservation CRUD, check-in/out
    ├── guests/        # Guest management
    └── reports/       # Export PDF/Excel
```

---

## Setup & Menjalankan

### 1. Prasyarat

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
- Android emulator / device

### 2. Jalankan Database & API

```bash
# Dari root project
docker compose up -d

# Cek status
docker compose ps
```

Setelah up:

- **PostgREST API**: http://localhost:3000
- **pgAdmin**: http://localhost:5050
  - Email: `admin@guesthouse.com`
  - Password: `admin123`

### 3. Install Flutter dependencies

```bash
flutter pub get
```

### 4. Jalankan aplikasi

```bash
flutter run
```

> **Catatan**: Android emulator mengakses localhost host machine via `10.0.2.2`.
> Sudah dikonfigurasi di `lib/core/constants/app_constants.dart`.

---

## Default Credentials (Development)

| Role        | Email                 | Password |
| ----------- | --------------------- | -------- |
| Admin       | admin@guesthouse.com  | admin123 |
| Resepsionis | resep1@guesthouse.com | resep123 |

---

## Properti & Kamar

| Properti                   | Tipe Kamar                | Jumlah |
| -------------------------- | ------------------------- | ------ |
| Guest House Deluxe         | Double Bed (`*`)          | ~18    |
| Guest House Deluxe         | Family Room (`**`)        | ~20    |
| Guest House Deluxe         | Longstay/Big Room (`***`) | ~10    |
| Guest House VIIP (Accasia) | VIP Room                  | 6      |

---

## Konvensi Commit

Project ini menggunakan [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: tambah fitur baru
fix: perbaikan bug
docs: perubahan dokumentasi
style: formatting, bukan perubahan logika
refactor: refaktor kode
test: tambah atau perbaiki test
chore: update dependencies, konfigurasi
```

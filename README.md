# Core Business System Gym

Dokumen ini merangkum core bisnis sistem gym berdasarkan analisis ekosistem aplikasi yang terdiri dari aplikasi web admin dan aplikasi mobile member.

## Ringkasan Sistem

Sistem ini adalah ekosistem manajemen gym berbasis SaaS. Sistem tidak hanya melayani satu cabang gym, tetapi dirancang untuk banyak perusahaan gym atau tenant. Setiap perusahaan dapat mengelola profil bisnis, cabang, member, paket membership, benefit, trainer, dan aktivitas booking. Di sisi lain, member gym memakai aplikasi mobile untuk melihat membership aktif, menemukan cabang, melakukan booking kelas atau personal trainer, dan melihat riwayat aktivitas.

Core bisnis utamanya adalah mengubah operasional gym manual menjadi sistem terpusat: perusahaan gym mengelola layanan dan data operasional melalui web admin, sementara member mendapatkan pengalaman self-service melalui aplikasi mobile.

## Struktur Komponen Utama

Sistem terdiri dari beberapa komponen utama:

- Aplikasi web admin untuk admin platform dan admin perusahaan gym.
- Aplikasi mobile untuk member gym.
- Backup migrasi database dari perubahan schema sebelumnya.

## Aktor Bisnis

- Platform Admin: pengelola SaaS, paket platform, tenant/perusahaan gym, subscription, invoice, dan permission global.
- Owner Gym: pemilik tenant/perusahaan gym yang memiliki akses penuh ke data perusahaannya.
- Gym Manager: pengelola operasional gym, member, membership, cabang, trainer, dan booking.
- Front Desk: staf harian untuk input member, membership, dan kebutuhan layanan member.
- Trainer: pelatih yang terkait dengan sesi personal training atau kelas.
- Member: pelanggan gym yang memiliki membership dan memakai aplikasi mobile.

## Core Bisnis Sistem

### 1. SaaS Multi-Tenant untuk Perusahaan Gym

Aplikasi web admin menyimpan konsep tenant melalui model `Company`. Setiap perusahaan gym memiliki data, staff, role, cabang, member, paket membership, trainer, dan booking sendiri. Ini menjadi dasar agar satu platform bisa dipakai oleh banyak bisnis gym tanpa data antar perusahaan tercampur.

Model bisnis SaaS juga terlihat dari model `PlatformPlan`, `CompanySubscription`, dan `PlatformInvoice`. Artinya platform dirancang untuk menjual paket langganan kepada perusahaan gym, termasuk billing cycle, batas seat/staff, trial, invoice, dan status subscription.

### 2. Manajemen Identitas dan Akses

Sistem membedakan akun internal/staff dan akun member mobile.

Untuk staff web admin, sistem memakai `User`, `UserSession`, `CompanyMembership`, `CompanyRole`, `Permission`, `CompanyRolePermission`, dan `MembershipRole`. Role template yang disiapkan mencakup owner, gym manager, front desk, dan trainer. Permission mengatur akses ke modul seperti dashboard, company profile, locations, members, memberships, plans, trainers, bookings, dan reports.

Untuk member mobile, sistem memakai `MemberCredential`, `MemberSession`, `MemberPasswordSetupToken`, dan `MemberPasswordChangeCode`. Ini memungkinkan member dibuat oleh staff, menerima link setup password, login dari aplikasi mobile, mengganti password, dan memiliki sesi terpisah dari staff.

### 3. Manajemen Cabang Gym

Cabang gym direpresentasikan oleh `Location`, `LocationFacility`, `LocationImage`, dan `LocationSchedule`. Modul ini menyimpan nama cabang, alamat, kontak, koordinat, fasilitas, gambar, jadwal operasional, dan status cabang.

Di aplikasi mobile member, fitur lokasi sudah dibuat sebagai pengalaman member: pencarian cabang, filter semua/terdekat/buka sekarang/24 jam, detail cabang, fasilitas, jadwal, trainer, tombol telepon, dan integrasi arah lokasi melalui `url_launcher`.

### 4. Manajemen Member

Member adalah pelanggan gym yang dikelola oleh perusahaan. Backend memakai model `Member` untuk data pelanggan, status, kode member, kontak, tanggal lahir, gender, alamat, dan relasi ke membership, credential, session, benefit, serta booking.

Pada web admin, modul members sudah memiliki service dan API untuk list, detail, create, update, delete, profile, serta pengiriman link setup password member. Ini menjadi proses awal agar pelanggan gym dapat masuk ke aplikasi mobile.

### 5. Paket Membership, Masa Aktif, dan Renewal

Revenue utama gym berasal dari paket membership. Model `MembershipPlan` menyimpan nama paket, harga, billing cycle, durasi hari, status aktif, dan benefit bawaan. Model `MemberMembership` menyimpan membership yang diambil member, tanggal mulai, tanggal berakhir, status pending/active/expired/cancelled, renewal, dan cancellation.

Backend sudah menyiapkan alur create, update, cancel, renew, delete, validasi overlap membership, dan statistik membership seperti total, active, pending, expiring soon, dan cancelled. Ini adalah inti operasional komersial gym karena menentukan siapa yang aktif, kapan membership habis, dan kapan perlu renewal.

### 6. Benefit Membership dan Pemakaian Layanan

Benefit adalah hak layanan yang melekat pada paket membership, misalnya kuota personal training, akses kelas, atau benefit lain. Model `MembershipPlanBenefit` mendefinisikan benefit pada paket, sedangkan `MemberBenefitGrant` dan `MemberBenefitUsage` mencatat benefit yang diberikan ke member dan pemakaiannya.

Konsep ini penting karena sistem tidak hanya menjual masa aktif membership, tetapi juga mengontrol kuota layanan yang bisa dipakai member. Benefit dapat berasal dari membership, manual, promo, atau pembelian eksternal.

### 7. Trainer, Personal Training, dan Kelas

Model `Trainer`, `PersonalTrainingBooking`, dan `ClassBooking` menunjukkan arah bisnis layanan latihan. Booking dapat berasal dari benefit membership, custom session, manual, atau trial. Status booking mencakup requested, scheduled, completed, cancelled, dan no show.

Di aplikasi mobile member, layar booking sudah menampilkan dua jalur layanan utama:

- PT Session: booking personal trainer berdasarkan coach, spesialisasi, lokasi, slot, benefit, dan detail program.
- Kelas: booking group class seperti Pilates, Zumba, Yoga, dan HIIT berdasarkan kategori, coach, slot, branch, level, dan benefit.

Saat ini sisi mobile masih banyak memakai data lokal/statis untuk pengalaman UI booking, sedangkan backend sudah menyiapkan model database untuk booking PT dan kelas.

### 8. Aktivitas Member

Aplikasi mobile member memiliki modul activity untuk menampilkan riwayat kedatangan, personal training, dan kelas. Data yang ditampilkan saat ini masih statis, tetapi arah domainnya jelas: member dapat melihat jejak check-in, sesi PT yang sudah selesai, kelas yang diikuti, tanggal, jam, trainer/coach, cabang, dan durasi.

Modul ini menjadi dasar untuk retention dan customer engagement karena member bisa memantau aktivitas latihan dan penggunaan layanan.

## Alur Bisnis Utama

1. Platform admin menyiapkan paket SaaS dan mengelola tenant gym.
2. Owner atau gym manager mendaftarkan dan mengatur profil perusahaan gym.
3. Staff mengelola cabang, fasilitas, jadwal, dan informasi lokasi.
4. Staff membuat paket membership beserta harga, durasi, dan benefit.
5. Staff mendaftarkan member dan mengirim link setup password mobile.
6. Member login ke aplikasi mobile member.
7. Member melihat kartu membership, status aktif, jadwal terdekat, dan reminder renewal.
8. Member mencari cabang, melihat fasilitas, jadwal, trainer, dan akses lokasi.
9. Member memilih layanan PT session atau kelas.
10. Sistem mencatat booking dan pemakaian benefit.
11. Staff memantau membership yang aktif, akan habis, dibatalkan, atau perlu renewal.

## Model Data Inti

```text
Platform SaaS:
  PlatformPlan
  CompanySubscription
  PlatformInvoice

Tenant Gym:
  Company
  CompanyMembership
  CompanyRole
  Permission

Operasional Cabang:
  Location
  LocationFacility
  LocationImage
  LocationSchedule

Member dan Membership:
  Member
  MemberCredential
  MemberSession
  MembershipPlan
  MemberMembership

Benefit dan Layanan:
  MembershipPlanBenefit
  MemberBenefitGrant
  MemberBenefitUsage
  Trainer
  PersonalTrainingBooking
  ClassBooking
```

## Aplikasi Web Admin

Fungsi utama:

- Authentication: register, login, logout, Google OAuth, reset password, verify email.
- Platform dashboard: overview tenant, platform subscription, invoice, dan rencana billing SaaS.
- Company dashboard: ringkasan operasional perusahaan gym.
- Company profile: identitas bisnis, kontak, logo, dan status.
- Locations: CRUD cabang, fasilitas, gambar, jadwal, koordinat, dan data mobile.
- Members: CRUD pelanggan gym, profile member, dan password setup member.
- Memberships: create, update, cancel, renew, delete, statistik, dan validasi masa aktif.
- Membership plans: create paket membership, harga, durasi, billing cycle, dan benefit.
- Roles & access: role staff dan permission per modul.
- Mobile API: login member, logout member, data member saat ini, lokasi cabang, dan perubahan password member.

Teknologi utama:

- Next.js 16
- React 19
- TypeScript
- Prisma 7
- MySQL/MariaDB
- Ant Design
- Nodemailer
- Argon2 password hashing

## Aplikasi Mobile Member

Fungsi utama:

- Login member.
- Home dashboard member.
- Kartu membership aktif.
- Reminder renewal membership.
- Jadwal terdekat.
- Navigasi Home, Lokasi, Booking, Activity, Profile.
- Lokasi cabang dengan search, filter, detail, fasilitas, jadwal, trainer, telepon, dan maps.
- Booking PT session dan kelas.
- Detail layanan dan booking success screen.
- Activity history untuk kedatangan, PT, dan kelas.

Teknologi utama:

- Flutter
- Dart
- Material 3
- `url_launcher` untuk telepon/maps

Catatan implementasi mobile:

- `lib/core/endpoints.dart` masih kosong, sehingga integrasi API belum didefinisikan di aplikasi Flutter.
- Data lokasi, booking, membership card, jadwal, dan activity di mobile saat ini banyak berbasis data lokal/statis.
- Backend sudah memiliki beberapa endpoint mobile yang bisa dihubungkan berikutnya: login, logout, `me`, lokasi, request password change, dan confirm password change.

## Status Implementasi Saat Ini

Yang sudah kuat:

- Struktur domain SaaS multi-tenant.
- Schema database gym cukup lengkap.
- Modul web untuk company profile, locations, members, memberships, dan plans.
- Role dan permission internal perusahaan.
- Auth staff dan auth member mobile.
- UI mobile untuk pengalaman member utama.

Yang masih perlu dilanjutkan:

- Integrasi nyata aplikasi mobile ke API backend web admin.
- Endpoint mobile untuk booking PT dan kelas.
- Endpoint mobile untuk activity/check-in.
- Halaman web penuh untuk trainers, PT bookings, classes, dan benefit activity.
- Sinkronisasi data statis mobile menjadi data dari database.

## Kesimpulan Core Business

Core bisnis sistem ini adalah platform SaaS untuk mengelola operasional dan revenue gym dari dua sisi:

1. Sisi perusahaan gym: mengelola tenant, cabang, staff, role, member, paket membership, renewal, benefit, trainer, booking, dan aktivitas operasional.
2. Sisi member: memberikan akses mobile untuk melihat membership, mencari cabang, melakukan booking layanan gym, dan memantau aktivitas latihan.

Dengan desain ini, sistem diarahkan menjadi produk SaaS B2B2C: platform menjual sistem ke bisnis gym, lalu bisnis gym memberikan aplikasi dan layanan digital kepada membernya.

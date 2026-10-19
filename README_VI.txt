TAKEBOOK - BO GIAO DIEN THU NGHIEM CHO VERCEL

Cac tep:
- index.html: giao dien cua hang TakeBook moi (trang chu).
- admin.html: giao dien quan tri sach, dang nhap Supabase Auth.
- setup.sql: SQL tao bang books, admin_users, RLS va bucket anh bia theo cau hinh hien tai cua admin.html.

CACH XEM GIAO DIEN
1. Giai nen goi nay.
2. Mo index.html bang Chrome de xem ban giao dien.
3. Mo admin.html de xem trang quan tri; can cau hinh Supabase va tai khoan admin de dang nhap su dung.

CACH DEPLOY LEN VERCEL (BAN THU NGHIEM)
1. Tao mot repository GitHub moi.
2. Tai len index.html vao thu muc goc cua repository.
3. Import repository do vao Vercel, Framework Preset chon Other, sau do Deploy.
4. Neu muon dua trang quan tri len cung domain, tai admin.html len cung thu muc goc; sau deploy mo /admin.html.

LUU Y QUAN TRONG
- index.html la giao dien moi de xem thu; chua duoc xac nhan ket noi dong bo voi bang BookProduct dang co.
- admin.html hien dang su dung bang `books`, bucket `book-covers` va bang `admin_users`.
- setup.sql se tao bang `books` moi, khong tu dong chuyen du lieu tu `BookProduct`.
- KHONG chay setup.sql tren du an dang co truoc khi kiem tra schema va sao luu du lieu.
- Khong dua Supabase service_role/secret key vao HTML hay ma chay tren trinh duyet.
- Chua chuyen ten mien chinh sang ban nay cho den khi kiem tra xong ket noi du lieu, gio hang va quy trinh dat hang.

#!/usr/bin/env bash
set -euo pipefail

# 0) Kiểm tra git repo
if [ ! -d .git ]; then
  echo "👉 Hãy chạy script ở root repo (có thư mục .git)."
  exit 1
fi

echo "✅ Bắt đầu tích hợp i18n backend (PHP)…"

# 1) Tạo nhánh an toàn
git checkout -b feat/i18n-ru-zhCN || true

# 2) Tạo thư mục lang/
mkdir -p lang

# 3) Tạo i18n.php
cat > i18n.php <<'PHP'
<?php
// Backend-only i18n for wefun-template3
// Layer 1: key-based dictionary via __('key', 'fallback')
// Layer 2: full-page backend replace via lang/{locale}_replace.php
declare(strict_types=1);

function i18n_supported(): array {
  return ['vi','en','ru','zh-CN'];
}

function i18n_map_filename(string $locale): string {
  $map = ['zh-CN'=>'zh_CN','zh_CN'=>'zh_CN','ru'=>'ru','vi'=>'vi','en'=>'en'];
  $key = $map[$locale] ?? 'vi';
  return __DIR__."/lang/{$key}.php";
}

function i18n_load(?string $locale=null): void {
  if ($locale===null) {
    $locale = $_GET['lang'] ?? ($_COOKIE['lang'] ?? 'vi');
  }
  $file = i18n_map_filename($locale);
  if (!file_exists($file)) $file = i18n_map_filename('vi');
  $GLOBALS['__i18n'] = require $file;
  $GLOBALS['__i18n_locale'] = $locale;
  if (!headers_sent()) {
    setcookie('lang', $locale, time()+60*60*24*30, '/');
  }
}

function __(string $key, string $fallback=''): string {
  $dict = $GLOBALS['__i18n'] ?? [];
  if (isset($dict[$key])) return $dict[$key];
  return $fallback!=='' ? $fallback : $key;
}

function __e(string $key, string $fallback=''): void {
  echo htmlspecialchars(__( $key, $fallback), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// Layer 2: full HTML replace on the backend
function i18n_start(): void {
  if (!isset($GLOBALS['__i18n'])) i18n_load();
  ob_start('i18n_filter');
}

function i18n_filter(string $html): string {
  $locale = $GLOBALS['__i18n_locale'] ?? 'vi';
  if ($locale==='vi' || $locale==='en') return $html; // keep original as-is
  $file = __DIR__."/lang/{$locale}_replace.php";
  if (!file_exists($file)) return $html;
  $map = require $file;
  if (!is_array($map) || !$map) return $html;
  return strtr($html, $map);
}

// Backend language switcher (no JS)
function i18n_select_html(): string {
  $current = $GLOBALS['__i18n_locale'] ?? ($_COOKIE['lang'] ?? 'vi');
  $opts = ['vi'=>'Tiếng Việt','en'=>'English','ru'=>'Русский','zh-CN'=>'简体中文'];
  $action = htmlspecialchars(strtok($_SERVER['REQUEST_URI'],'?'));
  $html  = '<form method="get" action="'.$action.'" class="i18n-switcher" style="display:inline-block">';
  $html .= '<select name="lang" onchange="this.form.submit()">';
  foreach ($opts as $code=>$label) {
    $sel = ($current===$code)?' selected':'';
    $html .= '<option value="'.htmlspecialchars($code).'"'.$sel.'>'.htmlspecialchars($label).'</option>';
  }
  $html .= '</select>';
  foreach ($_GET as $k=>$v) {
    if ($k==='lang') continue;
    $html .= '<input type="hidden" name="'.htmlspecialchars($k).'" value="'.htmlspecialchars((string)$v).'">';
  }
  $html .= '</form>';
  return $html;
}
PHP

# 4) Tạo lang/en.php
cat > lang/en.php <<'PHP'
<?php
return [
  // NAV
  'nav.home' => 'Home',
  'nav.google' => 'Google',
  'nav.tiktok' => 'TikTok',
  'nav.meta' => 'Meta',
  'nav.contact' => 'Contact us',

  // HERO / GENERIC
  'hero.title' => 'Grow your business with us',
  'hero.subtitle' => 'Smart solutions for Google, TikTok and Meta.',

  // BUTTONS / COMMON
  'btn.learn_more' => 'Learn more',
  'btn.contact_us' => 'Contact us',
  'btn.read_more' => 'Read more',
  'btn.submit' => 'Submit',
  'btn.send' => 'Send',

  // CONTACT
  'contact.title' => 'Send us a message',
  'contact.name' => 'Name',
  'contact.email' => 'Email',
  'contact.phone' => 'Phone',
  'contact.message' => 'Message',
  'contact.send' => 'Send message',

  // FOOTER
  'footer.about' => 'About',
  'footer.solutions' => 'Solutions',
  'footer.products' => 'Products',
  'footer.features' => 'Features',
  'footer.demo' => 'Demo',
  'footer.pricing' => 'Pricing',
  'footer.contact' => 'Contact',
  'footer.privacy' => 'Privacy',
  'footer.terms' => 'Terms',
  'footer.rights' => 'All rights reserved.',
];
PHP

# 5) Tạo lang/vi.php
cat > lang/vi.php <<'PHP'
<?php
return [
  // NAV
  'nav.home' => 'Trang chủ',
  'nav.google' => 'Google',
  'nav.tiktok' => 'TikTok',
  'nav.meta' => 'Meta',
  'nav.contact' => 'Liên hệ',

  // HERO / GENERIC
  'hero.title' => 'Phát triển doanh nghiệp cùng chúng tôi',
  'hero.subtitle' => 'Giải pháp thông minh cho Google, TikTok và Meta.',

  // BUTTONS / COMMON
  'btn.learn_more' => 'Tìm hiểu thêm',
  'btn.contact_us' => 'Liên hệ',
  'btn.read_more' => 'Xem thêm',
  'btn.submit' => 'Gửi',
  'btn.send' => 'Gửi',

  // CONTACT
  'contact.title' => 'Gửi tin nhắn cho chúng tôi',
  'contact.name' => 'Họ và tên',
  'contact.email' => 'Email',
  'contact.phone' => 'Số điện thoại',
  'contact.message' => 'Nội dung',
  'contact.send' => 'Gửi liên hệ',

  // FOOTER
  'footer.about' => 'Giới thiệu',
  'footer.solutions' => 'Giải pháp',
  'footer.products' => 'Sản phẩm',
  'footer.features' => 'Tính năng',
  'footer.demo' => 'Demo',
  'footer.pricing' => 'Bảng giá',
  'footer.contact' => 'Liên hệ',
  'footer.privacy' => 'Bảo mật',
  'footer.terms' => 'Điều khoản',
  'footer.rights' => 'Đã đăng ký bản quyền.',
];
PHP

# 6) Tạo lang/ru.php
cat > lang/ru.php <<'PHP'
<?php
return [
  // NAV
  'nav.home' => 'Главная',
  'nav.google' => 'Google',
  'nav.tiktok' => 'TikTok',
  'nav.meta' => 'Meta',
  'nav.contact' => 'Связаться с нами',

  // HERO / GENERIC
  'hero.title' => 'Развивайте свой бизнес вместе с нами',
  'hero.subtitle' => 'Умные решения для Google, TikTok и Meta.',

  // BUTTONS / COMMON
  'btn.learn_more' => 'Подробнее',
  'btn.contact_us' => 'Связаться',
  'btn.read_more' => 'Читать далее',
  'btn.submit' => 'Отправить',
  'btn.send' => 'Отправить',

  // CONTACT
  'contact.title' => 'Свяжитесь с нами',
  'contact.name' => 'Имя',
  'contact.email' => 'Эл. почта',
  'contact.phone' => 'Телефон',
  'contact.message' => 'Сообщение',
  'contact.send' => 'Отправить сообщение',

  // FOOTER
  'footer.about' => 'О нас',
  'footer.solutions' => 'Решения',
  'footer.products' => 'Продукты',
  'footer.features' => 'Функции',
  'footer.demo' => 'Демо',
  'footer.pricing' => 'Цены',
  'footer.contact' => 'Контакты',
  'footer.privacy' => 'Конфиденциальность',
  'footer.terms' => 'Условия',
  'footer.rights' => 'Все права защищены.',
];
PHP

# 7) Tạo lang/zh_CN.php
cat > lang/zh_CN.php <<'PHP'
<?php
return [
  // NAV
  'nav.home' => '首页',
  'nav.google' => 'Google',
  'nav.tiktok' => '抖音',
  'nav.meta' => 'Meta',
  'nav.contact' => '联系我们',

  // HERO / GENERIC
  'hero.title' => '与我们一起发展您的业务',
  'hero.subtitle' => '面向 Google、抖音与 Meta 的智能解决方案。',

  // BUTTONS / COMMON
  'btn.learn_more' => '了解更多',
  'btn.contact_us' => '联系我们',
  'btn.read_more' => '阅读更多',
  'btn.submit' => '提交',
  'btn.send' => '发送',

  // CONTACT
  'contact.title' => '给我们留言',
  'contact.name' => '姓名',
  'contact.email' => '邮箱',
  'contact.phone' => '电话',
  'contact.message' => '留言',
  'contact.send' => '发送留言',

  // FOOTER
  'footer.about' => '关于我们',
  'footer.solutions' => '解决方案',
  'footer.products' => '产品',
  'footer.features' => '功能',
  'footer.demo' => '演示',
  'footer.pricing' => '价格',
  'footer.contact' => '联系我们',
  'footer.privacy' => '隐私政策',
  'footer.terms' => '条款',
  'footer.rights' => '版权所有。',
];
PHP

# 8) Tạo map replace toàn trang (RU)
cat > lang/ru_replace.php <<'PHP'
<?php
return [
  'Home' => 'Главная',
  'Overview' => 'Обзор',
  'Features' => 'Функции',
  'Solutions' => 'Решения',
  'Demo' => 'Демо',
  'Pricing' => 'Цены',
  'Products' => 'Продукты',
  'Contact us' => 'Связаться с нами',
  'Contact' => 'Контакты',
  'Send us a message' => 'Свяжитесь с нами',
  'Name' => 'Имя',
  'Email' => 'Эл. почта',
  'Phone' => 'Телефон',
  'Message' => 'Сообщение',
  'Send message' => 'Отправить сообщение',
  'Learn more' => 'Подробнее',
  'Read more' => 'Читать далее',
  'Submit' => 'Отправить',
  'All rights reserved.' => 'Все права защищены.',
  'Grow your business with us' => 'Развивайте свой бизнес вместе с нами',
  'Smart solutions for Google, TikTok and Meta.' => 'Умные решения для Google, TikTok и Meta.',
];
PHP

# 9) Tạo map replace toàn trang (ZH-CN)
cat > lang/zh_CN_replace.php <<'PHP'
<?php
return [
  'Home' => '首页',
  'Overview' => '概览',
  'Features' => '功能',
  'Solutions' => '解决方案',
  'Demo' => '演示',
  'Pricing' => '价格',
  'Products' => '产品',
  'Contact us' => '联系我们',
  'Contact' => '联系我们',
  'Send us a message' => '给我们留言',
  'Name' => '姓名',
  'Email' => '邮箱',
  'Phone' => '电话',
  'Message' => '留言',
  'Send message' => '发送留言',
  'Learn more' => '了解更多',
  'Read more' => '阅读更多',
  'Submit' => '提交',
  'All rights reserved.' => '版权所有。',
  'Grow your business with us' => '与我们一起发展您的业务',
  'Smart solutions for Google, TikTok and Meta.' => '面向 Google、抖音与 Meta 的智能解决方案。',
];
PHP

# 10) Hàm chèn require + i18n_start vào đầu file PHP an toàn
insert_i18n_bootstrap () {
  local f="$1"
  [ -f "$f" ] || return 0
  # Nếu đã chèn trước đó, bỏ qua
  if grep -q "i18n_start" "$f" || grep -q "require __DIR__['\"']/i18n.php" "$f"; then
    echo "   • Bỏ qua $f (đã có i18n)"
    return 0
  fi

  # Nếu file bắt đầu bằng <?php thì thêm ngay sau dòng đầu
  if head -n1 "$f" | grep -q "^<\?php"; then
    sed -i '1a require __DIR__."/i18n.php"; i18n_start();' "$f"
  else
    # Không có mở thẻ PHP ở đầu: chèn block PHP vào đầu file
    sed -i '1i <?php require __DIR__."/i18n.php"; i18n_start(); ?>' "$f"
  fi
  echo "   • Đã chèn i18n vào $f"
}

# 11) Chèn vào các entry phổ biến (nếu tồn tại)
for f in index.php google.php tiktok.php meta.php contact.php Template.php; do
  insert_i18n_bootstrap "$f"
done

# 12) Gợi ý thêm language switcher (tuỳ bạn đặt vào header)
if ! grep -q "i18n_select_html" Template.php 2>/dev/null; then
  if [ -f Template.php ]; then
    echo -e "\n<!-- Bạn có thể hiển thị switcher ở đâu đó trong Template.php -->" >> Template.php
    echo -e "<?php /* <div class=\"lang-switcher\"><?= i18n_select_html() ?></div> */ ?>" >> Template.php
  fi
fi

# 13) Kiểm tra PHP syntax
php -l i18n.php >/dev/null
php -l lang/en.php >/dev/null
php -l lang/vi.php >/dev/null
php -l lang/ru.php >/dev/null
php -l lang/zh_CN.php >/dev/null
php -l lang/ru_replace.php >/dev/null
php -l lang/zh_CN_replace.php >/dev/null

# 14) Commit
git add i18n.php lang/ *.php || true
git commit -m "feat(i18n): backend i18n (vi/en/ru/zh-CN) + full-page replace + bootstrap into entries" || true

echo "✨ Hoàn tất! Thử truy cập:"
echo "   • Mặc định (vi): http://localhost/... "
echo "   • Nga        : ?lang=ru"
echo "   • Trung (简体): ?lang=zh-CN"

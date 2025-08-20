<?php
declare(strict_types=1);

function i18n_supported(): array {
  return ['en','vi','ru','zh-CN'];
}

function i18n_map_filename(string $locale): string {
  $map = ['zh-CN'=>'zh_CN','zh_CN'=>'zh_CN','ru'=>'ru','vi'=>'vi','en'=>'en'];
  $key = $map[$locale] ?? 'en';
  return __DIR__."/lang/{$key}.php";
}

function i18n_load(?string $locale=null): void {
  if ($locale===null) {
    // chỉ lấy query string, fallback en
    $locale = $_GET['lang'] ?? 'en';
  }
  $file = i18n_map_filename($locale);
  if (!file_exists($file)) $file = i18n_map_filename('en');
  $GLOBALS['__i18n'] = require $file;
  $GLOBALS['__i18n_locale'] = $locale;
}

function __(string $key, string $fallback=''): string {
  $dict = $GLOBALS['__i18n'] ?? [];
  if (isset($dict[$key])) return $dict[$key];
  return $fallback!=='' ? $fallback : $key;
}

function __e(string $key, string $fallback=''): void {
  echo htmlspecialchars(__( $key, $fallback), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// Layer 2: replace toàn trang
function i18n_start(): void {
  if (!isset($GLOBALS['__i18n'])) i18n_load();
  ob_start('i18n_filter');
}

function i18n_filter(string $html): string {
  $locale = $GLOBALS['__i18n_locale'] ?? 'en';
  if ($locale==='en') return $html; // mặc định giữ nguyên
  $file = __DIR__."/lang/{$locale}_replace.php";
  if (!file_exists($file)) return $html;
  $map = require $file;
  if (!is_array($map) || !$map) return $html;
  return strtr($html, $map);
}

// Language switcher
function i18n_select_html(): string {
  $current = $GLOBALS['__i18n_locale'] ?? 'en';
  $opts = ['en'=>'English','ru'=>'Русский','zh_CN'=>'简体中文'];
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

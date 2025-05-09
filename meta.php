<?php
include 'Template.php';
$config = include 'config.php';
Template::view('views/master-detail.html', [
    'platform' => 'Meta',
    'title' => 'Meta - Advertising accounts',
    'config' => $config,
    'text1' => 'Fast-track scale with whitelisted advertising accounts on Meta',
    'text2' => 'Skyrocket your business success with dedicated support, cashback, fewer bans, fewer restrictions, and cost-effective results - all managed through a single platform.',
    'image1' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/668e4cb2be57eb3f2e244289_Meta%20posts.png',
    'image2' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/6785e8de277e4fa4c77c003f_meta-box.png'
]);
?>

<?php
include 'Template.php';
$config = include 'config.php';
Template::view('views/master-detail.html', [
    'title' => 'TikTok - Advertising accounts',
    'config' => $config,
    'text1' => 'Advertising accounts on TikTok',
    'text2' => 'Unlock viral scalability with the fastest-growing social platform. Enjoy effortless campaign launches with fewer bans, dedicated support and more profitable results.',
    'image1' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/66c5e6f2bdef58524bee2edd_mm-tiktok.png',
    'image3' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/668e60b3a41ada3ee79aa960_p-feature-3.png', 
    'image2' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/6785eb589cdc2c947e93b696_tiktok-box.png'

]);
?>

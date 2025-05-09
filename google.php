<?php
include 'Template.php';
$config = include 'config.php';
Template::view('views/master-detail.html', [
    'platform' => 'Google',
    'title' => 'Google - Advertising accounts',
    'config' => $config,
    'text1' => 'Drive brand growth with whitelisted advertising accounts on Google',
    'text2' => 'Turn brand awareness into profit through the endless reach of the Google ecosystem. Launch targeted campaigns with compliance support, dedicated guidance, lower costs and profitable growth.',
    'image1' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/66c7fda7d196c0a78a566d95_google-posts.png',
    'image2' => 'https://cdn.prod.website-files.com/668b3733f80ed0dcd2c46207/6785ec587ab65c7e4db3c85f_google-box.png'
]);
?>

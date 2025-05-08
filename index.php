<?php
include 'Template.php';
$config = include 'config.php';
Template::view('views/index.html', ['config' => $config, 'title' => 'AdsAsia - Home Page']);
?>

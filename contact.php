<?php

// Đọc request từ form 
// Đọc telegram_bot_token và telegram_chat_id từ mảng trả về ở config.php 
// Gửi dữ liệu từ form tới telegram dựa trên config


$config = include 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $tele = $_POST['tele'] ?? '';
    $vertical = $_POST['vertical'] ?? '';
    $budget = $_POST['budget'] ?? '';
    $message = $_POST['message'] ?? '';

    if (!empty($message)) {
        $telegramBotToken = $config['telegram_bot_token'] ?? '';
        $telegramChatId = $config['telegram_chat_id'] ?? '';

        if (!empty($telegramBotToken) && !empty($telegramChatId)) {
            $telegramApiUrl = "https://api.telegram.org/bot$telegramBotToken/sendMessage";

            $sendText = "New contact from $name:\nTelegram: $tele\nEmail: $email\nVerticals: $vertical\nMonthly Budget: $budget\nMessage: $message";

            $data = [
                'chat_id' => $telegramChatId,
                'text' => $sendText
            ];

            $options = [
                'http' => [
                    'header' => "Content-type: application/x-www-form-urlencoded\r\n",
                    'method' => 'POST',
                    'content' => http_build_query($data),
                ],
            ];

            $context = stream_context_create($options);
            $result = file_get_contents($telegramApiUrl, false, $context);

            if ($result === false) {
                echo json_encode(['success' => false, 'message' => 'Unable to send the message.']);
            } else {
                echo json_encode(['success' => true, 'message' => 'Contact sent successfully.']);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Telegram bot token or chat ID is missing in the configuration.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Message cannot be empty.']);
    }
}

?>
<?php

namespace App\Services;

use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;

class FcmService
{
    protected $messaging;

    public function __construct()
    {
        $this->messaging = app('firebase.messaging');
    }

    /**
     * Kirim push notification ke satu device (FCM v1)
     */
    public function sendToDevice(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        try {
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::new()
                ->toToken($fcmToken)
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->send($message);
            return true;

        } catch (\Exception $e) {
            Log::error('FCM v1 Error: ' . $e->getMessage());
            return false;
        }
    }
}
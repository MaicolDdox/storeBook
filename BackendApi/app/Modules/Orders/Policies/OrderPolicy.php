<?php

namespace App\Modules\Orders\Policies;

use App\Models\Order;
use App\Models\User;

class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        return $user->hasRole('admin') || $order->user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->hasAnyRole(['admin', 'client']);
    }

    public function updateStatus(User $user, Order $order): bool
    {
        return $user->hasRole('admin');
    }
}

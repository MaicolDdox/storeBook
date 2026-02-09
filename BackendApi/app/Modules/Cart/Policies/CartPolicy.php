<?php

namespace App\Modules\Cart\Policies;

use App\Models\Cart;
use App\Models\User;

class CartPolicy
{
    public function view(User $user, Cart $cart): bool
    {
        return $user->hasRole('admin') || $cart->user_id === $user->id;
    }

    public function update(User $user, Cart $cart): bool
    {
        return $user->hasRole('admin') || $cart->user_id === $user->id;
    }
}

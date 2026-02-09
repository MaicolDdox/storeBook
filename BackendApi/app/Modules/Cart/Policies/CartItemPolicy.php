<?php

namespace App\Modules\Cart\Policies;

use App\Models\CartItem;
use App\Models\User;

class CartItemPolicy
{
    public function view(User $user, CartItem $cartItem): bool
    {
        return $user->hasRole('admin') || $cartItem->cart->user_id === $user->id;
    }

    public function update(User $user, CartItem $cartItem): bool
    {
        return $user->hasRole('admin') || $cartItem->cart->user_id === $user->id;
    }

    public function delete(User $user, CartItem $cartItem): bool
    {
        return $user->hasRole('admin') || $cartItem->cart->user_id === $user->id;
    }
}

<?php

namespace App\Models;

/**
 * Legacy compatibility model.
 * Use App\Models\Cart and App\Models\CartItem for all new code.
 */
class ShoppingCart extends CartItem
{
    protected $table = 'cart_items';
}

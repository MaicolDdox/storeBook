<?php

namespace App\Http\Controllers;

class ShoppingCartController extends Controller
{
    public function __call(string $name, array $arguments)
    {
        abort(410, 'Legacy controller is deprecated. Use module-based routes.');
    }
}

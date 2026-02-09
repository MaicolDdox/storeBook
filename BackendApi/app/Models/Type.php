<?php

namespace App\Models;

/**
 * Legacy compatibility model.
 * Use App\Models\Genre for all new code.
 */
class Type extends Genre
{
    protected $table = 'genres';
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShoppingCart extends Model
{
    use HasFactory;

    protected $fillable =
    [
        'total',
    ];

    //Relacion con book
    public function books():BelongsTo
    {
        return $this->belongsTo(Book::class, 'book_id');
    }
}

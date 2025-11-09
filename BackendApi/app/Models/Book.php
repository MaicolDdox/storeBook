<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Book extends Model
{
    use HasFactory;

    protected $fillable =
    [
        'category_id',
        'titulo',
        'foto',
        'descripccion_larga',
        'autor',
        'editorial',
        'year',
        'numero_paginas',
        'stock',
        'precio',
        'estado',
    ];

    //Relacion con categoria
    public function categories():BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    //Relacion con shopping_carts
    public function shopping_cart():HasMany
    {
        return $this->hasMany(ShoppingCart::class);
    }
}

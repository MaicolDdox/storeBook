<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Book extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'title',
        'slug',
        'cover_image',
        'description',
        'author',
        'publisher',
        'published_year',
        'page_count',
        'stock_quantity',
        'price_cents',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'published_year' => 'integer',
            'page_count' => 'integer',
            'stock_quantity' => 'integer',
            'price_cents' => 'integer',
        ];
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function cartItems(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function scopeAvailable(Builder $query): Builder
    {
        return $query
            ->where('status', 'available')
            ->where('stock_quantity', '>', 0);
    }
}

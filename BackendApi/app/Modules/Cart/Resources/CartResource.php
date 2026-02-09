<?php

namespace App\Modules\Cart\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\Cart
 */
class CartResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $itemCount = $this->items->sum('quantity');
        $subtotal = $this->items->sum('total_price_cents');

        return [
            'id' => $this->id,
            'status' => $this->status,
            'item_count' => $itemCount,
            'subtotal_cents' => $subtotal,
            'items' => CartItemResource::collection($this->whenLoaded('items')),
        ];
    }
}

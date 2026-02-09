<?php

namespace App\Modules\Orders\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\Payment
 */
class PaymentResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'method' => $this->method,
            'status' => $this->status,
            'amount_cents' => $this->amount_cents,
            'transaction_reference' => $this->transaction_reference,
            'paid_at' => $this->paid_at?->toISOString(),
        ];
    }
}

<?php

namespace App\Modules\Orders\Policies;

use App\Models\Address;
use App\Models\User;

class AddressPolicy
{
    public function view(User $user, Address $address): bool
    {
        return $user->hasRole('admin') || $address->user_id === $user->id;
    }

    public function update(User $user, Address $address): bool
    {
        return $user->hasRole('admin') || $address->user_id === $user->id;
    }

    public function delete(User $user, Address $address): bool
    {
        return $user->hasRole('admin') || $address->user_id === $user->id;
    }
}

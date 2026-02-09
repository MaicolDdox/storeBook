<?php

namespace App\Modules\Auth\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Spatie\Permission\Models\Role;

class AuthService
{
    /**
     * @param  array<string, mixed>  $payload
     * @return array{user: User, token: string}
     */
    public function register(array $payload): array
    {
        $user = User::create([
            'name' => $payload['name'],
            'email' => $payload['email'],
            'password' => $payload['password'],
        ]);

        if (! Role::query()->where('name', 'client')->exists()) {
            Role::create(['name' => 'client']);
        }

        $user->assignRole('client');

        $token = $user->createToken(
            $payload['device_name'] ?? 'web-or-mobile'
        )->plainTextToken;

        return [
            'user' => $user->fresh(),
            'token' => $token,
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{user: User, token: string}
     */
    public function login(array $payload): array
    {
        $user = User::query()->where('email', $payload['email'])->first();

        if (! $user || ! Hash::check($payload['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are invalid.'],
            ]);
        }

        $token = $user->createToken(
            $payload['device_name'] ?? 'web-or-mobile'
        )->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }
}

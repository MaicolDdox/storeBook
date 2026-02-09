<?php

namespace App\Modules\Catalog\Policies;

use App\Models\Book;
use App\Models\User;

class BookPolicy
{
    public function viewAny(?User $user): bool
    {
        return true;
    }

    public function view(?User $user, Book $book): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return $user->hasRole('admin');
    }

    public function update(User $user, Book $book): bool
    {
        return $user->hasRole('admin');
    }

    public function delete(User $user, Book $book): bool
    {
        return $user->hasRole('admin');
    }
}

<?php

namespace Database\Seeders;

use App\Models\Genre;
use Illuminate\Database\Seeder;

class TypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Genre::query()->firstOrCreate([
            'name' => 'Fiction',
        ], [
            'description' => 'Fiction genre',
        ]);

        Genre::query()->firstOrCreate([
            'name' => 'Non-Fiction',
        ], [
            'description' => 'Non-fiction genre',
        ]);
    }
}

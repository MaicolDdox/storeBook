<?php

namespace Database\Seeders;

use App\Models\Book;
use App\Models\Category;
use App\Models\Genre;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CatalogSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $seedStructure = [
            'Fiction' => [
                'Fantasy',
                'Science Fiction',
                'Mystery',
            ],
            'Non-Fiction' => [
                'Business',
                'Self Development',
                'History',
            ],
        ];

        foreach ($seedStructure as $genreName => $categoryNames) {
            $genre = Genre::query()->firstOrCreate(
                ['name' => $genreName],
                ['description' => "{$genreName} books"]
            );

            foreach ($categoryNames as $categoryName) {
                $category = Category::query()->firstOrCreate(
                    ['slug' => Str::slug($categoryName)],
                    [
                        'genre_id' => $genre->id,
                        'name' => $categoryName,
                        'description' => "{$categoryName} category",
                    ]
                );

                Book::factory()
                    ->count(2)
                    ->create(['category_id' => $category->id]);
            }
        }
    }
}

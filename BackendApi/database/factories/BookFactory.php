<?php

namespace Database\Factories;

use App\Models\Book;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Book>
 */
class BookFactory extends Factory
{
    protected $model = Book::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $title = fake()->unique()->sentence(3);

        return [
            'category_id' => Category::factory(),
            'title' => $title,
            'slug' => Str::slug($title).'-'.fake()->unique()->numberBetween(10, 9999),
            'cover_image' => null,
            'description' => fake()->paragraph(),
            'author' => fake()->name(),
            'publisher' => fake()->company(),
            'published_year' => fake()->numberBetween(1950, 2025),
            'page_count' => fake()->numberBetween(80, 1200),
            'stock_quantity' => fake()->numberBetween(1, 40),
            'price_cents' => fake()->numberBetween(799, 5999),
            'status' => 'available',
        ];
    }
}

<?php

namespace Database\Factories;

/**
 * Legacy compatibility factory.
 * Use GenreFactory for new tests and seeders.
 */
class TypeFactory extends GenreFactory
{
    protected $model = \App\Models\Type::class;
}

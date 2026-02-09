<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $this->migrateLegacyTypesToGenres();
        $this->migrateLegacyCategories();
        $this->migrateLegacyBooks();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // This migration only backfills data and adds compatibility columns.
    }

    private function migrateLegacyTypesToGenres(): void
    {
        if (! Schema::hasTable('types') || ! Schema::hasTable('genres')) {
            return;
        }

        if (! Schema::hasColumn('types', 'name')) {
            return;
        }

        $legacyTypes = DB::table('types')->select(['id', 'name', 'descripccion'])->get();

        foreach ($legacyTypes as $legacyType) {
            DB::table('genres')->updateOrInsert(
                ['id' => $legacyType->id],
                [
                    'name' => match ($legacyType->name) {
                        'ficcion' => 'fiction',
                        'no ficcion' => 'non-fiction',
                        default => (string) $legacyType->name,
                    },
                    'description' => $legacyType->descripccion,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }

    private function migrateLegacyCategories(): void
    {
        if (! Schema::hasTable('categories')) {
            return;
        }

        Schema::table('categories', function (Blueprint $table): void {
            if (! Schema::hasColumn('categories', 'genre_id')) {
                $table->foreignId('genre_id')->nullable()->after('id');
            }

            if (! Schema::hasColumn('categories', 'slug')) {
                $table->string('slug')->nullable()->after('name');
            }

            if (! Schema::hasColumn('categories', 'description')) {
                $table->string('description')->nullable()->after('slug');
            }
        });

        if (Schema::hasColumn('categories', 'type_id')) {
            DB::table('categories')
                ->whereNull('genre_id')
                ->update(['genre_id' => DB::raw('type_id')]);
        }

        if (Schema::hasColumn('categories', 'descripccion')) {
            DB::table('categories')
                ->whereNull('description')
                ->update(['description' => DB::raw('descripccion')]);
        }

        $categories = DB::table('categories')->select(['id', 'name', 'slug'])->get();
        foreach ($categories as $category) {
            if (! empty($category->slug)) {
                continue;
            }

            $baseSlug = Str::slug((string) $category->name);
            $slug = $baseSlug === '' ? 'category' : $baseSlug;

            $suffix = 1;
            while (
                DB::table('categories')
                    ->where('slug', $slug)
                    ->where('id', '!=', $category->id)
                    ->exists()
            ) {
                $suffix++;
                $slug = "{$baseSlug}-{$suffix}";
            }

            DB::table('categories')
                ->where('id', $category->id)
                ->update(['slug' => $slug]);
        }
    }

    private function migrateLegacyBooks(): void
    {
        if (! Schema::hasTable('books')) {
            return;
        }

        Schema::table('books', function (Blueprint $table): void {
            if (! Schema::hasColumn('books', 'title')) {
                $table->string('title')->nullable()->after('category_id');
            }

            if (! Schema::hasColumn('books', 'slug')) {
                $table->string('slug')->nullable()->after('title');
            }

            if (! Schema::hasColumn('books', 'cover_image')) {
                $table->string('cover_image')->nullable()->after('slug');
            }

            if (! Schema::hasColumn('books', 'description')) {
                $table->text('description')->nullable()->after('cover_image');
            }

            if (! Schema::hasColumn('books', 'author')) {
                $table->string('author')->nullable()->after('description');
            }

            if (! Schema::hasColumn('books', 'publisher')) {
                $table->string('publisher')->nullable()->after('author');
            }

            if (! Schema::hasColumn('books', 'published_year')) {
                $table->unsignedSmallInteger('published_year')->nullable()->after('publisher');
            }

            if (! Schema::hasColumn('books', 'page_count')) {
                $table->unsignedSmallInteger('page_count')->nullable()->after('published_year');
            }

            if (! Schema::hasColumn('books', 'stock_quantity')) {
                $table->unsignedInteger('stock_quantity')->default(0)->after('page_count');
            }

            if (! Schema::hasColumn('books', 'price_cents')) {
                $table->unsignedInteger('price_cents')->default(0)->after('stock_quantity');
            }

            if (! Schema::hasColumn('books', 'status')) {
                $table->string('status')->default('available')->after('price_cents');
            }
        });

        if (Schema::hasColumn('books', 'titulo')) {
            DB::table('books')
                ->whereNull('title')
                ->update(['title' => DB::raw('titulo')]);
        }

        if (Schema::hasColumn('books', 'foto')) {
            DB::table('books')
                ->whereNull('cover_image')
                ->update(['cover_image' => DB::raw('foto')]);
        }

        if (Schema::hasColumn('books', 'descripccion_larga')) {
            DB::table('books')
                ->whereNull('description')
                ->update(['description' => DB::raw('descripccion_larga')]);
        }

        if (Schema::hasColumn('books', 'autor')) {
            DB::table('books')
                ->whereNull('author')
                ->update(['author' => DB::raw('autor')]);
        }

        if (Schema::hasColumn('books', 'editorial')) {
            DB::table('books')
                ->whereNull('publisher')
                ->update(['publisher' => DB::raw('editorial')]);
        }

        if (Schema::hasColumn('books', 'year')) {
            DB::table('books')
                ->whereNull('published_year')
                ->update(['published_year' => DB::raw('year')]);
        }

        if (Schema::hasColumn('books', 'numero_paginas')) {
            DB::table('books')
                ->whereNull('page_count')
                ->update(['page_count' => DB::raw('numero_paginas')]);
        }

        if (Schema::hasColumn('books', 'stock')) {
            DB::table('books')
                ->where('stock_quantity', 0)
                ->update(['stock_quantity' => DB::raw('stock')]);
        }

        if (Schema::hasColumn('books', 'precio')) {
            DB::table('books')
                ->where('price_cents', 0)
                ->update(['price_cents' => DB::raw('precio')]);
        }

        if (Schema::hasColumn('books', 'estado')) {
            DB::table('books')
                ->where('estado', 'agotado')
                ->update(['status' => 'out_of_stock']);

            DB::table('books')
                ->where('estado', 'disponible')
                ->update(['status' => 'available']);
        }

        $books = DB::table('books')->select(['id', 'title', 'slug'])->get();
        foreach ($books as $book) {
            if (! empty($book->slug)) {
                continue;
            }

            $baseSlug = Str::slug((string) $book->title);
            $slug = $baseSlug === '' ? 'book' : $baseSlug;

            $suffix = 1;
            while (
                DB::table('books')
                    ->where('slug', $slug)
                    ->where('id', '!=', $book->id)
                    ->exists()
            ) {
                $suffix++;
                $slug = "{$baseSlug}-{$suffix}";
            }

            DB::table('books')->where('id', $book->id)->update(['slug' => $slug]);
        }
    }
};

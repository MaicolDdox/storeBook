<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('books', function (Blueprint $table) {
            $table->id();

            //Relaciones con Category
            $table->foreignId('category_id')->constrained('categories')->onDelete('CASCADE');

            $table->string('titulo');
            $table->string('foto');
            $table->text('descripccion_larga');
            $table->string('autor');
            $table->string('editorial');
            $table->string('year');
            $table->string('numero_paginas');
            $table->integer('stock');
            $table->integer('precio');
            $table->enum('estado', ['agotado', 'disponible'])->default('disponible');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('books');
    }
};

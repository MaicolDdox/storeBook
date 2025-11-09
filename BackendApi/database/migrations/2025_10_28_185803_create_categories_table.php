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
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('type_id')->constrained('types')->onDelete('CASCADE');
            $table->enum('name', [
                                    'Ciencia ficcion',
                                    'Fantasia',
                                    'Terror',
                                    'Romance',
                                    'Misterio y suspense',
                                    'Novela negra',
                                    'Thriller',
                                    'Distopia',
                                    'Western',
                                    'Historia',
                                    'Divulgacion cientifica',
                                    'Autoayuda y superacion personal',
                                    'Politica',
                                    'Ciencias sociales',
                                    'Memorias',
                                    'Filosofia',
                                    'Religion'
                                ]);
                                ;
            $table->string('descripccion')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};

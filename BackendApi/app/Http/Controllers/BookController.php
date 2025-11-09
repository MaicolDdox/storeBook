<?php

namespace App\Http\Controllers;

use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class BookController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $books = Book::all();
        return response()->json($books, 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id'        => ['required', 'exists:categories,id'],
            'titulo'             => ['required', 'string', 'max:30'],
            'foto'               => ['required', 'string', 'max:255'],
            'descripccion_larga' => ['required', 'string', 'max:65535'],
            'autor'              => ['required', 'string', 'max:50'],
            'editorial'          => ['required', 'string', 'max:50'],
            'year'               => ['required', 'string', 'max:4'],
            'numero_paginas'     => ['required', 'string', 'max:255'],
            'stock'              => ['required', 'integer'],
            'precio'             => ['required', 'integer'],
            'estado'             => ['required', Rule::in(['disponible', 'agotado'])],
        ]);

        $book= new Book($validated);
        $book->save();

        return response()->json([
            'data'    => $book,
            'message' => 'Libro agregadocorrectamente',
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Book $book)
    {
        return response()->json([
            'data'    => $book,
            'message' => 'Ok'
        ], 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Book $book)
    {
        $validated = $request->validate([
            'category_id'        => ['sometimes', 'exists:categories,id'],
            'titulo'             => ['sometimes', 'string', 'max:30'],
            'foto'               => ['sometimes', 'string', 'max:255'],
            'descripccion_larga' => ['sometimes', 'string', 'max:65535'],
            'autor'              => ['sometimes', 'string', 'max:50'],
            'editorial'          => ['sometimes', 'string', 'max:50'],
            'year'               => ['sometimes', 'string', 'max:4'],
            'numero_paginas'     => ['sometimes', 'string', 'max:255'],
            'stock'              => ['sometimes', 'integer'],
            'precio'             => ['sometimes', 'integer'],
            'estado'             => ['sometimes', Rule::in(['disponible', 'agotado'])],
        ]);

        $book->update($validated);

        return response()->json([
            'data'    => $book,
            'message' => 'Libro actualizado correctamente',
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Book $book)
    {
        $book->delete();

        return response()->json([
            'data' => $book,
            'message' => 'Libro con ID ' . $book->id . ' eliminado correctamente',
        ], 200);
    }
}

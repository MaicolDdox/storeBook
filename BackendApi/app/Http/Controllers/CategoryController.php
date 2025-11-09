<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $categories = Category::all();

        return response()->json($categories, 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type_id'      => ['required', 'exists:types,id'],
            'name'         => ['required', 'string', Rule::in(['Ciencia ficcion',
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
                                                                'Religion'])],
            'descripccion' => ['required', 'string', 'max:255'],
        ]);

        $category = new Category($validated);
        $category->save();

        return response()->json([
            'data' => $category,
            'message' => 'Categoría creada correctamente'
        ], 201);

    }

    /**
     * Display the specified resource.
     */
    public function show(Category $category)
    {
        return response()->json([
            'data' => $category,
            'message' => 'Ok'
        ], 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Category $category)
    {
        $validated = $request->validate([
            'type_id'      => ['sometimes', 'exists:types,id'],
            'name'         => ['sometimes', 'string', Rule::in(['Ciencia ficcion',
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
                                                                'Religion'])],
            'descripccion' => ['sometimes', 'string', 'max:255'],
        ]);

        $category->update($validated);

        return response()->json([
            'data'    => $category,
            'message' => 'categoria actualizada correctamente',
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Category $category)
    {
        $category->delete();

        return response()->json([
            'data' => $category,
            'message' => 'Categoria con ID ' . $category->id . ' eliminado correctamente',
        ], 200);
    }
}

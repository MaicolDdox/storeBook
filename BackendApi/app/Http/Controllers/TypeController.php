<?php

namespace App\Http\Controllers;

use App\Models\Type;
use Dom\HTMLElement;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TypeController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $types = Type::all();
        return response()->json($types, 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'         => ['required', Rule::in(['ficcion', 'no ficcion'])],
            'descripccion' => ['required', 'string', 'max:255'],
        ]);

        $type = new Type($validated);
        $type->save();

        return response()->json([
            'data'    => $type,
            'message' => 'Genero creado correctamente',
        ], 201);

    }

    /**
     * Display the specified resource.
     */
    public function show(Type $type)
    {
        return response()->json([
            'data'    => $type,
            'message' => 'Ok'
        ], 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Type $type)
    {
        $validated = $request->validate([
            'name'         => ['nullable', Rule::in(['ficcion', 'no ficcion'])],
            'descripccion' => ['nullable', 'string', 'max:255'],
        ]);

        $type->update($validated);

        return response()->json([
            'data'    => $type,
            'message' => 'Genero de libro editado correctamente',
        ], 200);

    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Type $type)
    {
        $type->delete();

        return response()->json([
            'data'    => $type,
            'message' => 'Genero con ID ' . $type->id . ' eliminado correctamente',
        ], 200);
    }
}

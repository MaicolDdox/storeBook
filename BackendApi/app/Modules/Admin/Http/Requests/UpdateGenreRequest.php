<?php

namespace App\Modules\Admin\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateGenreRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $genreId = (int) $this->route('genre')?->id;

        return [
            'name' => ['sometimes', 'string', 'max:120', Rule::unique('genres', 'name')->ignore($genreId)],
            'description' => ['nullable', 'string', 'max:255'],
        ];
    }
}

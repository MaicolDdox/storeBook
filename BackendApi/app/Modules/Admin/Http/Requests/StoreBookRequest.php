<?php

namespace App\Modules\Admin\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreBookRequest extends FormRequest
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
        return [
            'category_id' => ['required', 'integer', 'exists:categories,id'],
            'title' => ['required', 'string', 'max:180'],
            'cover_image' => ['nullable', 'string', 'max:255'],
            'image' => ['nullable', 'file', 'image', 'mimes:jpg,jpeg,png,webp,gif', 'max:5120'],
            'description' => ['required', 'string', 'max:65535'],
            'author' => ['required', 'string', 'max:120'],
            'publisher' => ['nullable', 'string', 'max:120'],
            'published_year' => ['nullable', 'integer', 'min:1450', 'max:2100'],
            'page_count' => ['nullable', 'integer', 'min:1', 'max:10000'],
            'stock_quantity' => ['required', 'integer', 'min:0'],
            'price_cents' => ['required', 'integer', 'min:1'],
            'status' => ['required', Rule::in(['available', 'out_of_stock', 'archived'])],
        ];
    }
}

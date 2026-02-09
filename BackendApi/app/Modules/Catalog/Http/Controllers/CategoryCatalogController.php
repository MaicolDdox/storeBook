<?php

namespace App\Modules\Catalog\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Catalog\Resources\CategoryResource;
use App\Modules\Catalog\Services\CatalogService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class CategoryCatalogController extends Controller
{
    public function __construct(
        private readonly CatalogService $catalogService
    ) {}

    public function index(Request $request)
    {
        $perPage = min((int) $request->integer('per_page', 20), 50);
        $categories = $this->catalogService->listCategories($perPage);

        return ApiResponse::paginated(
            'Categories retrieved successfully.',
            CategoryResource::collection($categories->items()),
            $categories
        );
    }
}

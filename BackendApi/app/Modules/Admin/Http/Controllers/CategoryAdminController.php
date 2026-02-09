<?php

namespace App\Modules\Admin\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Modules\Admin\Http\Requests\StoreCategoryRequest;
use App\Modules\Admin\Http\Requests\UpdateCategoryRequest;
use App\Modules\Admin\Services\AdminCatalogService;
use App\Modules\Catalog\Resources\CategoryResource;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CategoryAdminController extends Controller
{
    public function __construct(
        private readonly AdminCatalogService $catalogService
    ) {}

    public function index(Request $request)
    {
        $this->authorize('viewAny', Category::class);

        $categories = $this->catalogService->listCategories((int) $request->integer('per_page', 20));

        return ApiResponse::paginated(
            'Categories retrieved successfully.',
            CategoryResource::collection($categories->items()),
            $categories
        );
    }

    public function store(StoreCategoryRequest $request)
    {
        $this->authorize('create', Category::class);
        $category = $this->catalogService->createCategory($request->validated());

        return ApiResponse::success(
            'Category created successfully.',
            new CategoryResource($category),
            Response::HTTP_CREATED
        );
    }

    public function show(Category $category)
    {
        $this->authorize('view', $category);

        return ApiResponse::success(
            'Category retrieved successfully.',
            new CategoryResource($category->load('genre'))
        );
    }

    public function update(UpdateCategoryRequest $request, Category $category)
    {
        $this->authorize('update', $category);
        $category = $this->catalogService->updateCategory($category, $request->validated());

        return ApiResponse::success(
            'Category updated successfully.',
            new CategoryResource($category)
        );
    }

    public function destroy(Category $category)
    {
        $this->authorize('delete', $category);
        $this->catalogService->deleteCategory($category);

        return ApiResponse::success('Category deleted successfully.', null, Response::HTTP_OK);
    }
}

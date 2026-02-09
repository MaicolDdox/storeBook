<?php

namespace App\Modules\Catalog\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Modules\Catalog\Http\Requests\ListBooksRequest;
use App\Modules\Catalog\Resources\BookResource;
use App\Modules\Catalog\Services\CatalogService;
use App\Support\ApiResponse;

class BookCatalogController extends Controller
{
    public function __construct(
        private readonly CatalogService $catalogService
    ) {}

    public function index(ListBooksRequest $request)
    {
        $books = $this->catalogService->listBooks($request->validated());

        return ApiResponse::paginated(
            'Books retrieved successfully.',
            BookResource::collection($books->items()),
            $books
        );
    }

    public function show(Book $book)
    {
        $book->load(['category.genre']);

        return ApiResponse::success(
            'Book retrieved successfully.',
            new BookResource($book)
        );
    }
}

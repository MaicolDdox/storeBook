<?php

namespace App\Modules\Admin\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Modules\Admin\Http\Requests\StoreBookRequest;
use App\Modules\Admin\Http\Requests\UpdateBookRequest;
use App\Modules\Admin\Services\AdminCatalogService;
use App\Modules\Catalog\Resources\BookResource;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class BookAdminController extends Controller
{
    public function __construct(
        private readonly AdminCatalogService $catalogService
    ) {}

    public function index(Request $request)
    {
        $this->authorize('viewAny', Book::class);
        $books = $this->catalogService->listBooks((int) $request->integer('per_page', 20));

        return ApiResponse::paginated(
            'Books retrieved successfully.',
            BookResource::collection($books->items()),
            $books
        );
    }

    public function store(StoreBookRequest $request)
    {
        $this->authorize('create', Book::class);
        $book = $this->catalogService->createBook($request->validated());

        return ApiResponse::success(
            'Book created successfully.',
            new BookResource($book),
            Response::HTTP_CREATED
        );
    }

    public function show(Book $book)
    {
        $this->authorize('view', $book);

        return ApiResponse::success(
            'Book retrieved successfully.',
            new BookResource($book->load('category.genre'))
        );
    }

    public function update(UpdateBookRequest $request, Book $book)
    {
        $this->authorize('update', $book);
        $book = $this->catalogService->updateBook($book, $request->validated());

        return ApiResponse::success(
            'Book updated successfully.',
            new BookResource($book)
        );
    }

    public function destroy(Book $book)
    {
        $this->authorize('delete', $book);
        $this->catalogService->deleteBook($book);

        return ApiResponse::success('Book deleted successfully.', null, Response::HTTP_OK);
    }
}

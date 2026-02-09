<?php

namespace App\Modules\Admin\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Genre;
use App\Modules\Admin\Http\Requests\StoreGenreRequest;
use App\Modules\Admin\Http\Requests\UpdateGenreRequest;
use App\Modules\Admin\Services\AdminCatalogService;
use App\Modules\Catalog\Resources\GenreResource;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class GenreAdminController extends Controller
{
    public function __construct(
        private readonly AdminCatalogService $catalogService
    ) {}

    public function index(Request $request)
    {
        $this->authorize('viewAny', Genre::class);

        $genres = $this->catalogService->listGenres((int) $request->integer('per_page', 20));

        return ApiResponse::paginated(
            'Genres retrieved successfully.',
            GenreResource::collection($genres->items()),
            $genres
        );
    }

    public function store(StoreGenreRequest $request)
    {
        $this->authorize('create', Genre::class);
        $genre = $this->catalogService->createGenre($request->validated());

        return ApiResponse::success(
            'Genre created successfully.',
            new GenreResource($genre),
            Response::HTTP_CREATED
        );
    }

    public function show(Genre $genre)
    {
        $this->authorize('view', $genre);

        return ApiResponse::success(
            'Genre retrieved successfully.',
            new GenreResource($genre)
        );
    }

    public function update(UpdateGenreRequest $request, Genre $genre)
    {
        $this->authorize('update', $genre);
        $genre = $this->catalogService->updateGenre($genre, $request->validated());

        return ApiResponse::success(
            'Genre updated successfully.',
            new GenreResource($genre)
        );
    }

    public function destroy(Genre $genre)
    {
        $this->authorize('delete', $genre);
        $this->catalogService->deleteGenre($genre);

        return ApiResponse::success('Genre deleted successfully.', null, Response::HTTP_OK);
    }
}

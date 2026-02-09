<?php

namespace App\Modules\Catalog\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Catalog\Resources\GenreResource;
use App\Modules\Catalog\Services\CatalogService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class GenreCatalogController extends Controller
{
    public function __construct(
        private readonly CatalogService $catalogService
    ) {}

    public function index(Request $request)
    {
        $perPage = min((int) $request->integer('per_page', 20), 50);
        $genres = $this->catalogService->listGenres($perPage);

        return ApiResponse::paginated(
            'Genres retrieved successfully.',
            GenreResource::collection($genres->items()),
            $genres
        );
    }
}

<?php

namespace App\Providers;

use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;

class ModuleServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        $moduleDirectories = File::directories(app_path('Modules'));

        foreach ($moduleDirectories as $moduleDirectory) {
            $routeFile = $moduleDirectory.'/Routes/api.php';

            if (! File::exists($routeFile)) {
                continue;
            }

            Route::prefix('api')
                ->middleware('api')
                ->group($routeFile);
        }
    }
}

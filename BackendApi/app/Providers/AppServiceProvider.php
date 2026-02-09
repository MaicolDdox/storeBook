<?php

namespace App\Providers;

use App\Models\Address;
use App\Models\Book;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Category;
use App\Models\Genre;
use App\Models\Order;
use App\Modules\Cart\Policies\CartItemPolicy;
use App\Modules\Cart\Policies\CartPolicy;
use App\Modules\Catalog\Policies\BookPolicy;
use App\Modules\Catalog\Policies\CategoryPolicy;
use App\Modules\Catalog\Policies\GenrePolicy;
use App\Modules\Orders\Policies\AddressPolicy;
use App\Modules\Orders\Policies\OrderPolicy;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(Book::class, BookPolicy::class);
        Gate::policy(Category::class, CategoryPolicy::class);
        Gate::policy(Genre::class, GenrePolicy::class);
        Gate::policy(Cart::class, CartPolicy::class);
        Gate::policy(CartItem::class, CartItemPolicy::class);
        Gate::policy(Order::class, OrderPolicy::class);
        Gate::policy(Address::class, AddressPolicy::class);

        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(10)->by($request->ip());
        });

        RateLimiter::for('search', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });
    }
}

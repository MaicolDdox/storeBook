<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    'allowed_origins' => array_filter(array_map(
        static fn (string $origin): string => trim($origin),
        explode(
            ',',
            env(
                'CORS_ALLOWED_ORIGINS',
                'http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000,http://127.0.0.1:3000'
            )
        )
    )),
    'allowed_origins_patterns' => array_filter(array_map(
        static fn (string $pattern): string => trim($pattern),
        explode(
            ',',
            env(
                'CORS_ALLOWED_ORIGIN_PATTERNS',
                '#^https?://localhost(:\\d+)?$#,#^https?://127\\.0\\.0\\.1(:\\d+)?$#'
            )
        )
    )),
    'allowed_headers' => ['Accept', 'Authorization', 'Content-Type', 'Origin', 'X-Requested-With'],
    'exposed_headers' => ['Content-Type'],
    'max_age' => 3600,
    'supports_credentials' => false,
];

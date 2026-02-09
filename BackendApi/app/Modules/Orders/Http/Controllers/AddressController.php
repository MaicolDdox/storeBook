<?php

namespace App\Modules\Orders\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Modules\Orders\Http\Requests\StoreAddressRequest;
use App\Modules\Orders\Http\Requests\UpdateAddressRequest;
use App\Modules\Orders\Resources\AddressResource;
use App\Modules\Orders\Services\OrderService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AddressController extends Controller
{
    public function __construct(
        private readonly OrderService $orderService
    ) {}

    public function index(Request $request)
    {
        $addresses = $this->orderService->listUserAddresses($request->user());

        return ApiResponse::paginated(
            'Addresses retrieved successfully.',
            AddressResource::collection($addresses->items()),
            $addresses
        );
    }

    public function store(StoreAddressRequest $request)
    {
        $address = $this->orderService->createAddress($request->user(), $request->validated());

        return ApiResponse::success(
            'Address created successfully.',
            new AddressResource($address),
            Response::HTTP_CREATED
        );
    }

    public function update(UpdateAddressRequest $request, Address $address)
    {
        $this->authorize('update', $address);

        $updatedAddress = $this->orderService->updateAddress($address, $request->validated());

        return ApiResponse::success(
            'Address updated successfully.',
            new AddressResource($updatedAddress)
        );
    }

    public function destroy(Address $address)
    {
        $this->authorize('delete', $address);
        $address->delete();

        return ApiResponse::success('Address deleted successfully.', null, Response::HTTP_OK);
    }
}

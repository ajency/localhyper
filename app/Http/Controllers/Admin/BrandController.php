<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;

class BrandController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  Request  $request
     * @return Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  Request  $request
     * @param  int  $id
     * @return Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return Response
     */
    public function destroy($id)
    {
        //
    }

    public static function parseBrandImport($data){

        // $data =array (
        //   'brands' => 
        //   array (
        //     0 => 
        //     array (
        //       'objectId' => '',
        //       'imageUrl' => 'http://ajency.in/team/images/Electrolux-logo-2015.png',
        //       'name' => 'Airtel',
        //       ),
        //     1 => 
        //     array (
        //       'objectId' => 'ATjq0fGF0H',
        //       'imageUrl' => 'http://ajency.in/team/images/micromax-logo.png',
        //       'name' => 'Microoo',
        //       ),
        //     ),
        //   'categoryId' => 'wGA1ota1bd',
        //   );
      $functionName = "brandImport";

      $result = AttributeController::makeParseCurlRequest($functionName,$data); 

      return $result;
    }
}

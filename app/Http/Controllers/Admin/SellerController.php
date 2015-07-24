<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;

class SellerController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $seller = new ParseQuery("_User");
        $seller->equalTo("userType", "seller");
        $sellerData = $seller->find();  
        $sellerList =[];
        foreach($sellerData as $seller)
        {
 
             $sellerList[]= ['id' => $seller->getObjectId(),
                              'name' => $seller->get("displayName"),
                              'area' => $seller->get("area"),
                              'createdAt' =>$seller->getCreatedAt()->format('d-m-Y')
                              ];
        }
        return view('admin.sellerlist')->with('sellers',$sellerList);
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
     * @return Response
     */
    public function store()
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
     * @param  int  $id
     * @return Response
     */
    public function update($id)
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
}

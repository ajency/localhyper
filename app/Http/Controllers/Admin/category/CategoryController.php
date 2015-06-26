<?php

namespace App\Http\Controllers\Admin\category;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;

class CategoryController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */

    // listing /category
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    // add an item /category/create
    public function create()
    {
        
                return view('admin.category.add')
                        ->with('x1', 123)
                        ->with('x2', 'sdfsf');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @return Response
     */
    // for post method and path /category
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
    // path /category/catId
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
    //  /category/catId/edit
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
    // post /category/catId ; put in hidden
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

    // delete /category/catId ; 
    public function destroy($id)
    {
        //
    }
}

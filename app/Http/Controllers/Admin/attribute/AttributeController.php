<?php

namespace App\Http\Controllers\Admin\attribute;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use Parse\ParseObject;
use Parse\ParseQuery;
use \Session;

class AttributeController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $allAttributes = AttributeController::getParseAttributes();

        $attribList = array();

        // foreach ($allCategories as $catObject) {
        //       $catArr = array(
        //                     'id' =>$catObject->getObjectId(),
        //                     'name' => $catObject->get('name'),
        //                     'created_at' => $catObject->getCreatedAt(),
        //                     'modified_at' => $catObject->getUpdatedAt(),
        //                     );

        //       if (!$catObject->get('parent_category')) {
        //           $catArr['parent'] = 'None' ;
        //       }
        //       else{
        //         $parent_category = $catObject->get('parent_category');
        //         $parent_category->fetch();
        //         $catArr['parent'] = $parent_category->get('name');
        //       }

        //       $catList[] = $catArr;
              

        // } 

        return view('admin.attribute.list')
        ->with('categories', $attribList);
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

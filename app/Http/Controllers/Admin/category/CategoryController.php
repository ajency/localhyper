<?php

namespace App\Http\Controllers\Admin\category;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use Parse\ParseObject;

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
    public function store(Request $request)
    {
       
        $category_name = $request->input('category_name');
        $parent_category = $request->input('parent_category');
        $sort_id = $request->input('sort_id');

        $categoryData = $request->all();
        $catData = array(
            'name' => $categoryData['category_name'], 
            'description' => $categoryData['description'], 
            'sort_order' => (int)$categoryData['sort_id'], 
            'image' => array('src' => $categoryData['image_url']), 
            );

        $category = CategoryController::createParseCategory($catData);

        // return redirect("/admin/category/".$category);
        return redirect("/admin/category/create");

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

    public static function createParseCategory($categoryData){
       
        $category = new ParseObject("Category");
        $category->set("name", $categoryData['name']);
        $category->set("description", $categoryData['description']);
        // $category->set("parent_category", $categoryData['parent_category']);
        $category->set("sort_order", $categoryData['sort_order']);
        $category->setArray("image", $categoryData['image']);
        
        try {
          $category->save();
          // dd($category->getObjectId());
          // echo 'New object created with objectId: ' . $category->getObjectId();
          return $category->getObjectId();
        } 
        catch (ParseException $ex) {  
          // Execute any logic that should take place if the save fails.
          // error is a ParseException object with an error code and message.
              echo 'Failed to create new object, with error message: ' . $ex->getMessage();
              return $ex->getMessage();

        }

    }
}

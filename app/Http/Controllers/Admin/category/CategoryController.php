<?php

namespace App\Http\Controllers\Admin\category;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use Parse\ParseObject;
use Parse\ParseQuery;
use \Session;
use \Input;

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
        $allCategories = CategoryController::getParseCategories();

        $catList = array();

        foreach ($allCategories as $catObject) {
              $catArr = array(
                            'id' =>$catObject->getObjectId(),
                            'name' => $catObject->get('name'),
                            'created_at' => $catObject->getCreatedAt(),
                            'modified_at' => $catObject->getUpdatedAt(),
                            );

              if (!$catObject->get('parent_category')) {
                  $catArr['parent'] = 'None' ;
              }
              else{
                $parent_category = $catObject->get('parent_category');
                $parent_category->fetch();
                $catArr['parent'] = $parent_category->get('name');
              }

              $catList[] = $catArr;
              

        } 

        return view('admin.category.list')
        ->with('categories', $catList);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    // add an item /category/create
    public function create()
    {
        $allCategories = CategoryController::getParseCategories();

        $catList = array();

        CategoryController::getParentCategories();

        foreach ($allCategories as $catObject) {
              $catList[] = array(
                            'cat_id' =>$catObject->getObjectId(),
                            'cat_name' => $catObject->get('name')
                            );
              

        }
        return view('admin.category.add')
        ->with('categories', $catList);
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

        // get all category form data
        $categoryData = $request->all();

        // unset parent category if set as none ie root
        if ($categoryData['parent_category'] == "0"){
            unset($categoryData['parent_category']);
        }

        $catData = array(
            'name' => $categoryData['category_name'], 
            'description' => $categoryData['description'], 
            'sort_order' => (int)$categoryData['sort_id'], 
            'image' => array('src' => $categoryData['image_url']), 
            );

        // set parent category only if parent_category is set
        if (isset($categoryData['parent_category'])) {
           $catData['parent_category'] = $categoryData['parent_category'];
        }
        

        $create_category = CategoryController::createParseCategory($catData);

        if ($create_category['status']) {
           $request->session()->flash('success_message','Category Successfully added');
        }
        else{
           $request->session()->flash('error_message',$create_category['msg']); 
        }
        

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

    public static function getParentCategories(){

        $categoryQuery = new ParseQuery("Category");

        $categoryQuery->doesNotExist("parent_category");
        
        $results = $categoryQuery->find();

        foreach ($results as $catObject) {
          $parentCategories[] = array(
                'cat_id' =>$catObject->getObjectId(),
                'cat_name' => $catObject->get('name')
                );
          }

          return $parentCategories;

    }

    public function getChildCategory(){

        $getVar = Input::get(); 

        $categoryId = $getVar['categoryId'];

        $categoryQuery = new ParseQuery("Category");

        $categoryQuery->exists("parent_category");

        $innerQuery = new ParseQuery("Category");
        $innerQuery->equalTo("objectId",$categoryId);
        $categoryQuery->matchesQuery("parent_category", $innerQuery);
        
        
        $results = $categoryQuery->find();
       
        foreach ($results as $catObject) {
          $parentCategories[] = array(
                'cat_id' =>$catObject->getObjectId(),
                'cat_name' => $catObject->get('name')
                );
          }

          return $parentCategories;
    }

    public static function createParseCategory($categoryData){
       
        $category = new ParseObject("Category");
        $category->set("name", $categoryData['name']);
        $category->set("description", $categoryData['description']);
        
        $category->set("sort_order", $categoryData['sort_order']);
        $category->setArray("image", $categoryData['image']);

        if (isset($categoryData['parent_category'])) {
            // get parent category object by id
            $categoryQuery = new ParseQuery("Category");
            try {
              $parentCategory = $categoryQuery->get($categoryData['parent_category']);
              $category->set("parent_category", $parentCategory);


          } catch (ParseException $ex) {
              // The object was not retrieved successfully.
              // error is a ParseException with an error code and message.

              $resp = array('status' => 0 , 'msg' => 'Failed to create new object, with error message: '.$ex->getMessage());
              return $resp;
          }
        }



          try {
            $category->save();
            $resp = array('status' => 1 , 'data' => $category->getObjectId());
            return $resp;
          } 
          catch (ParseException $ex) {  
          // Execute any logic that should take place if the save fails.
          // error is a ParseException object with an error code and message.
              $resp = array('status' => 0 , 'msg' => 'Failed to create new object, with error message: '.$ex->getMessage());
              return $resp;

          } 

 

    }
    public static function getParseCategories($categoryFilter=[]){
       
        $categoryQuery = new ParseQuery("Category");
        
        $results = $categoryQuery->find();

        return $results;

    }    
}

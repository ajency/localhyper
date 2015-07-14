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

    public static function attributeImport($data){

        $data = array (
                  'attributes' => 
                  array (
                    0 => 
                    array (
                      'objectId' => 'vsX3NY2syg',
                      'name' => 'reen size',
                      'group' => 'general',
                      'unit' => 'inches',
                      'display_type' => 'checkbox',
                    ),
                    1 => 
                    array (
                      'objectId' => '',
                      'name' => 'tv color',
                      'group' => 'general',
                      'unit' => '',
                      'display_type' => 'checkbox',
                    ),
                  ),
                  'categoryId' => 'UPieAJ73Vk',
                  'isFilterable' => false,
                );

        $app_id = config('constants.parse_sdk.app_id');
        $rest_api_key = config('constants.parse_sdk.rest_api_key');
        $base_url = "https://api.parse.com/1";

        $parseFunctType = "functions";

        $functionName = "attributeImport";

        $post_url = $base_url."/".$parseFunctType."/".$functionName;

        $data_string = json_encode($data); 

        $header_array = array(                                                                          
        'X-Parse-Application-Id:' .$app_id ,                                                                                
        'X-Parse-REST-API-Key:' .$rest_api_key ,                                                                                
        'Content-Type: application/json',                                                                                
        'Content-Length: ' . strlen($data_string),
        );

          // -H "X-Parse-Application-Id: 837yxeNhLEJUXZ0ys2pxnxpmyjdrBnn7BcD0vMn7" \
          // -H "X-Parse-REST-API-Key: zdoU2CuhK5S1Dbi2WDb6Rcs4EgprFrrpiWx3fUBy" \
          // -H "Content-Type: application/json" \
          // -d '{}' \
          // https://api.parse.com/1/functions/hello 

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,$post_url);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);                                                                  
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
        curl_setopt($ch, CURLOPT_HTTPHEADER, $header_array)                                                                       
        );                                                                                                                   

        $result = curl_exec($ch);


        if (curl_errno($ch)) {

            $result_json  = 0;
        }
        else{

            $result_json  = (json_decode($result)!='')?json_decode($result):0;

        }

        /* Check HTTP Code */
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        curl_close($ch); 

        return $result_json;      
    
    }      
}

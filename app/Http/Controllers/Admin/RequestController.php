<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;

class RequestController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $requests = new ParseQuery("Request");
        $requests->includeKey('customerId');
        $requests->includeKey('product');
        $requests->includeKey('category');
        $requestsData = $requests->find(); 
        
        $requestList = $productPriceArray=[];
        
        foreach($requestsData as $request)
        {
            $productId = $request->get("product")->get("objectId");
            if(!isset($productPriceArray[$productId]))
            {
                $productPrice = new ParseQuery("Price");
                $productPrice->equalTo("product", $productId);
                $productPriceData = $productPrice->find();
                $priceArray = [];
                $onlinePrice = $platformPrice = '';
                foreach($productPriceData as $price)
                {
                    $priceType = $price->get("type");
                    if($priceType == 'online_market_price')
                    {
                        $onlinePrice = $price->get("value");
                    }
                    else{
                        $priceArray[] = $price->get("value");
                    }
                }
                $platformPrice = (!empty($priceArray))? array_sum($priceArray) / count($priceArray) .'/-' :'N/A'; 
                
                $productPriceArray[$productId]['OnlinePrice'] = $onlinePrice; 
                $productPriceArray[$productId]['PlatformPrice'] = $platformPrice; 
            }
            else
            {
                $onlinePrice = $productPriceArray[$productId]['OnlinePrice']; 
                $platformPrice = $productPriceArray[$productId]['PlatformPrice']; 
            }
            
            
            
            $requestList[]= ['id' => $request->getObjectId(),
                              'customerName' => $request->get("customerId")->get("displayName"),
                              'productName' =>$request->get("product")->get("name"),
                              'area' =>$request->get("area"),
                              'category' =>$request->get("category")->get("name"),
                              'mrp' =>$request->get("product")->get("mrp").'/-',
                              'onlinePrice' =>$onlinePrice.'/-',
                              'bestPlatformPrice' =>$platformPrice,
                              'offerCount' =>$request->get("offerCount"),
                              'status' =>$request->get("status"),
                              ];  
        }
        
        return view('admin.requestlist')->with('requestList',$requestList);
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

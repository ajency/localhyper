<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;

class OfferController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $offers = new ParseQuery("Offer");
        $offers->includeKey('seller');
        $offers->includeKey('request');
        $offers->includeKey('request.product');
        $offers->includeKey('price');
        $offersData = $offers->find(); 
       
        $offertList = $productRequests=[];
        
        foreach($offersData as $offer)
        {
            $requestObj= $offer->get("request");
            $productObj = $requestObj->get('product');
            $priceObj = $offer->get('price');  
            
            $productId  = $productObj->getObjectId(); 
            
            if(!isset($productRequests[$productId]))
            {
                $requestsinnerQuery  = new ParseQuery("Request");
                $requestsinnerQuery ->equalTo("product", $productObj);  
                
                $productRequests[$productId] = $requestsinnerQuery;
            }
            else
               $requestsinnerQuery = $productRequests[$productId];
           
            $lastSellerOffer = new ParseQuery("Offer");
            $lastSellerOffer->matchesQuery("request",$requestsinnerQuery);
            $lastSellerOffer->descending("CreatedAt");
            $lastOfferBySeller = $lastSellerOffer->first();  
            
            $offertList[] =[
                        'productName'=>$productObj->get("name"),
                        'modelNo'=>$productObj->get("model_number"),
                        'sellerName'=>$offer->get("seller")->get("displayName"),
                        'area'=>$offer->get("area"),
                        'mrpOfProduct'=>$productObj->get("mrp").'/-',   
                        'onlinePrice'=>$priceObj->get("value").'/-',
                        'offerPrice'=>$offer->get("offerPrice").'/-',
                        'lastOfferBySeller'=>$lastOfferBySeller->get("offerPrice").'/-',
                        'requestStatus'=>$requestObj->get("status"),
                        'offerStatus'=>$offer->get("status"),
                        'deliveryReasonFailure'=>($requestObj->get("failedDeliveryReason")!='')?$requestObj->get("failedDeliveryReason"):'N/A',
                        'date'=>$offer->getCreatedAt()->format('Y-m-d H:i:s'),
                         ] ;  
        }
        
        return view('admin.offerslist')->with('offerList',$offertList);
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

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
        $sellers = new ParseQuery("_User");
        $sellers->equalTo("userType", "seller");
        $sellers->includeKey('supportedCategories');
        $sellerData = $sellers->find();   
        $sellerList =[];
        foreach($sellerData as $seller)
        {  
             $categories =[];
             $supportedCategories =$seller->get("supportedCategories");
             foreach($supportedCategories as $supportedCategory)
             {
                 $categories[] =$supportedCategory->get('name');
             }
            
            $sellerId = $seller->getObjectId();
            
            $sellerRequests = new ParseQuery("Notification"); 
            $sellerRequests->equalTo("recipientUser", $seller);
            $sellerRequests->equalTo("type", "Request");
            $sellerRequestCount = $sellerRequests->count();
            
            $offer = new ParseQuery("Offer");
            $offer->equalTo("seller", $seller);
            $offertData = $offer->find();
            $offerCount = count($sellerId);
            $offerSuccessfullCount =  0;
            
            foreach($offertData as $offer)
            {
                if($offer->get("status")=='successfull')
                    $offerSuccessfullCount = $offerSuccessfullCount+1;
 
            }
            
             $balanceCredit = $seller->get("addedCredit") - $seller->get("subtractedCredit");
            
             $sellerList[]= ['id' => $seller->getObjectId(),
                              'name' => $seller->get("displayName"),
                              'area' => $seller->get("area"),
                              'categories' => implode(", ",$categories),
                              'offersCount' => $offerCount .'/'.$sellerRequestCount,
                              'successfullCount' => $offerSuccessfullCount,
                              'avgRating' => 'N/A',
                              'balanceCredit' => $balanceCredit,
                              'lastLogin' =>$seller->get("lastLogin")->format('d-m-Y'),
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
        $sellers = new ParseQuery("_User");
        $sellers->equalTo("objectId", $id);
        $sellers->includeKey('supportedCategories');
        $sellerData = $sellers->first();
       
         $categories =[];
         $supportedCategories = $sellerData->get("supportedCategories");  
         foreach($supportedCategories as $supportedCategory)
         {
             $categories[] =$supportedCategory->get('name');
         } 
       
        $seller['businessname'] = $sellerData->get("businessName"); 
        $seller['name'] = $sellerData->get("displayName"); 
        $seller['email'] = $sellerData->get("email"); 
        $seller['mobile'] =''; 
        $seller['deliveryRadius'] = $sellerData->get("deliveryRadius");
        $seller['address'] = $sellerData->get("address"); 
        $seller['area'] = $sellerData->get("area"); 
        $seller['city'] = $sellerData->get("city");
        $seller['categories'] = $categories; 
            
        $offers = new ParseQuery("Offer");
        $offers->equalTo("seller", $sellerData);
        $offers->includeKey('request');
        $offers->includeKey('request.product');
        $offers->includeKey('request.category');
        $offers->includeKey('Price');
        $offersData = $offers->find(); 
        
        $sellerOffers =$product = $category =[];
        foreach($offersData as $offer)
        {
            $requestObj= $offer->get("request");
            $productObj = $requestObj->get('product');
            $categoryObj = $requestObj->get('category');
            $priceObj = $offer->get('Price');
 
            $sellerOffers[] =[
                        'productName'=>$productObj->get("name"),
                        'category'=>$categoryObj->get("name"),
                        'offerAmt'=>$priceObj->get("amount"),
                        'status'=>$offer->get("status"),
                        'date'=>$offer->getCreatedAt()->format('Y-m-d H:i:s'),
                         ] ;
            
 

        }
 
 
        return view('admin.sellerdetails')->with('seller',$seller)
                                            ->with('selleroffers',$sellerOffers);
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

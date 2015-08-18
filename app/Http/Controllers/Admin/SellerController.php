<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;
use \PHPExcel;
use App\Http\Helper\FormatPhpExcel;

class SellerController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $sellersData = $this->getSellers('LIST');
        $sellerList = $sellersData['list'];
        $numOfPages = $sellersData['numOfPages'];
        $page = $sellersData['page'];

        return view('admin.sellerlist')->with('sellers',$sellerList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','sellers');
 
    }
    
    
    public function getSellers($type)
    {
        
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $numOfPages = 0;
        
        $sellers = new ParseQuery("_User");
        $sellers->equalTo("userType", "seller");
        $sellers->includeKey('supportedCategories');
        $sellers->includeKey('supportedBrands');
        
        if($type == 'LIST')
        {   //Pagination
            
            $displayLimit = config('constants.page_limit'); 
 
            $sellersCount = $sellers->count();  
            $sellers->limit($displayLimit);
            $sellers->skip($page * $displayLimit);
            
            $numOfPages = ceil($sellersCount/$displayLimit);
        }
        
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
            
             $brands =[];
             $supportedBrands =$seller->get("supportedBrands");
             foreach($supportedBrands as $supportedBrand)
             {
                 $brands[] =$supportedBrand->get('name');
             }
            
            $sellerId = $seller->getObjectId();
            
            $sellerRequests = new ParseQuery("Notification"); 
            $sellerRequests->equalTo("recipientUser", $seller);
            $sellerRequests->equalTo("type", "Request");
            $sellerRequestCount = $sellerRequests->count();
            
            $offer = new ParseQuery("Offer");
            $offer->equalTo("seller", $seller);
            $offerCount = $offer->count();
            $offertData = $offer->find();
            $offerSuccessfullCount =  0;
            
            foreach($offertData as $offer)
            {
                if($offer->get("status")=='successfull')
                    $offerSuccessfullCount = $offerSuccessfullCount+1;
 
            }
            
             $balanceCredit = $seller->get("addedCredit") - $seller->get("subtractedCredit");
            
            if($type=='LIST')
            {
                $sellerList[]= [ 'id' => $seller->getObjectId(),
                              'name' => $seller->get("displayName"),
                              'area' => $seller->get("area"),
                              'brands' => implode(", ",$brands),       
                              'categories' => implode(", ",$categories),
                              'offersCount' => $offerCount .'/'.$sellerRequestCount,
                              'successfullCount' => $offerSuccessfullCount,
                              'avgRating' => 'N/A',
                              'balanceCredit' => $balanceCredit,
                              'lastLogin' =>$seller->get("lastLogin")->format('d-m-Y'),
                              'createdAt' =>$seller->getCreatedAt()->format('d-m-Y')
                              ];
            }
            else
            {
                $sellerList[]= [
                              'name' => $seller->get("displayName"),
                              'area' => $seller->get("area"),
                              'brands' => implode(", ",$brands),       
                              'categories' => implode(", ",$categories),
                              'offersCount' => $offerCount .'/'.$sellerRequestCount,
                              'successfullCount' => $offerSuccessfullCount,
                              'avgRating' => 'N/A',
                              'balanceCredit' => $balanceCredit,
                              'lastLogin' =>$seller->get("lastLogin")->format('d-m-Y'),
                              'createdAt' =>$seller->getCreatedAt()->format('d-m-Y')
                              ];
            }
    
            
        }  
        
         $data['list']=$sellerList;
         $data['numOfPages']=$numOfPages;
         $data['page']=$page;
         return $data;
 
    }
    
    public function sellersExport()
    { 
        $excel = new PHPExcel();
        $sellersSheet = $excel->getSheet(0);
		$sellersSheet->setTitle('Sellers');
 
        $sellersData = $this->getSellers('EXPORT');
        $sellerList = $sellersData['list'];
        
        $headers = [];
 
        $headers []= 'SELLER NAME' ;
        $headers []= 'AREA' ;
        $headers []= 'Brands' ;
        $headers []= 'CATEGORY' ;
        $headers []= 'RESPONSE RATIO' ;
        $headers []= 'NO. OF SUCCESSFULL OFFERS' ;
        $headers []= 'AVG RATINGS' ;
        $headers []= 'BALANCE CREDITS' ;
        $headers []= 'REGISTERED DATE' ;
        $headers []= 'LAST LOGIN' ;
 
        						 
        $sellersSheet->fromArray($headers, ' ', 'A1');
        $sellersSheet->fromArray($sellerList, ' ','A2');


        //Headr row height
        $sellersSheet->getRowDimension('1')->setRowHeight(20);

        //Format header row
        FormatPhpExcel::format_header_row($sellersSheet, array(
            'background_color'=>'FFFF00',
            'border_color'=>'000000',
            'font_size'=>'9',
            'font_color'=>'000000',
            'vertical_alignment'=>'VERTICAL_CENTER',
            'font-weight'=>'bold'
            ), '1'
        );
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="sellers-export.xls"');
        header('Cache-Control: max-age=0');
        // If you're serving to IE 9, then the following may be needed
        header('Cache-Control: max-age=1');
        // If you're serving to IE over SSL, then the following may be needed
        header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
        header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); // always modified
        header ('Cache-Control: cache, must-revalidate'); // HTTP/1.1
        header ('Pragma: public'); // HTTP/1.0
        $objWriter = \PHPExcel_IOFactory::createWriter($excel, 'Excel5');
        $objWriter->save('php://output'); 
    
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
        $seller['id'] = $sellerData->getObjectId();
        $seller['businessname'] = $sellerData->get("businessName"); 
        $seller['name'] = $sellerData->get("displayName"); 
        $seller['email'] = '-'; 
        $seller['mobile'] =$sellerData->get("username"); 
        $seller['deliveryRadius'] = $sellerData->get("deliveryRadius");
        $seller['address'] = $sellerData->get("address"); 
        $seller['area'] = $sellerData->get("area"); 
        $seller['city'] = $sellerData->get("city");
        $seller['categories'] = $categories; 
        $showOffers = false;
        
        if(isset($_GET['page']))
        {
            $page =($_GET['page']-1);
            $showOffers = true;    
        }
        else
            $page =0; 
        $displayLimit = config('constants.page_limit'); 
        $numOfPages = 0;
        
        $offers = new ParseQuery("Offer");
        $offers->equalTo("seller", $sellerData);
        $offers->includeKey('request');
        $offers->includeKey('request.product');
        $offers->includeKey('request.category');
        $offers->includeKey('price');
        
        $requestCount = $offers->count();          //Pagination
        $offers->limit($displayLimit);
        $offers->skip($page * $displayLimit);

        $numOfPages = ceil($requestCount/$displayLimit);
        
        $offersData = $offers->find(); 
        
        $sellerOffers =$product = $category =[];
        foreach($offersData as $offer)
        {
            $requestObj= $offer->get("request");
            $productObj = $requestObj->get('product');
            $categoryObj = $requestObj->get('category');
            $priceObj =   $offer->get('price'); 
            
            $creditUsed =0;
            $transaction = new ParseQuery("Transaction");
            $transaction->equalTo("offer", $offer);
            $transactions = $transaction->find(); 
            foreach($transactions as $transaction)
            {
               $creditUsed += $transaction->get("creditCount");
            }
 
            $sellerOffers[] =[
                        'id'=>$offer->getObjectId(),
                        'productName'=>$productObj->get("name"),
                        'category'=>$categoryObj->get("name"),
                        'offerAmt'=>$priceObj->get("value"),
                        'creditUsed' => $creditUsed,
                        'status'=>$offer->get("status"),
                        'date'=>$offer->getCreatedAt()->format('Y-m-d H:i:s'),
                         ] ;
            
 

        }  
 
 
        return view('admin.sellerdetails')->with('seller',$seller)
                                          ->with('numOfPages',$numOfPages)
                                          ->with('page',$page+1)
                                          ->with('showOffers',$showOffers)    
                                          ->with('selleroffers',$sellerOffers)
                                          ->with('activeMenu','sellers');
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

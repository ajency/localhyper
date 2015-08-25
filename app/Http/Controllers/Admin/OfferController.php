<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;
use \PHPExcel;
use App\Http\Helper\FormatPhpExcel;

class OfferController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $offersData = $this->getOffers('LIST');
        $offertList = $offersData['list'];
        $numOfPages = $offersData['numOfPages'];
        $page = $offersData['page'];

        return view('admin.offerslist')->with('offerList',$offertList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','offers');
 
    }
    
    public function getOffers($type)
    {
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $numOfPages = 0;
        
        $offers = new ParseQuery("Offer");
        $offers->includeKey('seller');
        $offers->includeKey('request');
        $offers->includeKey('request.product');
        $offers->includeKey('price');
        
        if($type == 'LIST')
        {   //Pagination
            
            $displayLimit = config('constants.page_limit'); 
 
            $offersCount = $offers->count();  
            $offers->limit($displayLimit);
            $offers->skip($page * $displayLimit);
            
            $numOfPages = ceil($offersCount/$displayLimit);
        }
        
        $offersData = $offers->find(); 
       
        $offertList = $productRequests= $onlinePriceArray=[];
        
        foreach($offersData as $offer)
        {
            $requestObj= $offer->get("request");
            $productObj = $requestObj->get('product');
            $priceObj = $offer->get('price');  
            
            $requestId  = $requestObj->getObjectId(); 
            $productId  = $productObj->getObjectId();
            
            if(!isset($productRequests[$productId]))
            {
                $requestsinnerQuery  = new ParseQuery("Request");
                $requestsinnerQuery ->equalTo("product", $productObj);  
                
                $productRequests[$productId] = $requestsinnerQuery;
                
                $productPrice = new ParseQuery("Price");
                $productPrice->equalTo("type", "online_market_price");
                $productPrice->equalTo("product", $productObj);
                $productPrice->ascending("value");
                $productPriceData = $productPrice->first();
                
                $onlinePrice = (!empty($productPriceData))? $productPriceData->get("value").'/-' :'';
                $onlinePriceArray[$productId]['OnlinePrice'] = $onlinePrice; 
            }
            else
            {
               $requestsinnerQuery = $productRequests[$productId];
               $onlinePrice = $onlinePriceArray[$productId]['OnlinePrice']; 
            }
           
            $lastSellerOffer = new ParseQuery("Offer");
            $lastSellerOffer->matchesQuery("request",$requestsinnerQuery);
            $lastSellerOffer->descending("CreatedAt");
            $lastOfferBySeller = $lastSellerOffer->first();  
            
            if($type=='LIST')
            {
                $offertList[] =[
                        'id' => $offer->getObjectId(),
                        'requestId'=>$requestId,
                        'productName'=>$productObj->get("name"),
                        'modelNo'=>$productObj->get("model_number"),
                        'sellerName'=>$offer->get("seller")->get("displayName"),
                        'sellerId'=>$offer->get("seller")->getObjectId(),
                        'area'=>$offer->get("area"),
                        'mrpOfProduct'=>$productObj->get("mrp").'/-',   
                        'onlinePrice'=>$onlinePrice,
                        'offerPrice'=>$priceObj->get("value").'/-',
                        'lastOfferBySeller'=>$lastOfferBySeller->get("offerPrice").'/-',
                        'requestStatus'=>$requestObj->get("status"),
                        'offerStatus'=>$offer->get("status"),
                        'deliveryReasonFailure'=>($requestObj->get("failedDeliveryReason")!='')?$requestObj->get("failedDeliveryReason"):'N/A',
                        'date'=>convertToIST($offer->getCreatedAt()->format('d-m-Y H:i:s')), 
                         ] ;  
            }
            else
            {
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
                        'date'=>convertToIST($offer->getCreatedAt()->format('d-m-Y H:i:s')), 
                         ] ;  
            }
            
            
        }
        
        $data['list']=$offertList;
        $data['numOfPages']=$numOfPages;
        $data['page']=$page;
        return $data;
        
    }
    
    public function offersExport()
    { 
        $excel = new PHPExcel();
        $offerSheet = $excel->getSheet(0);
		$offerSheet->setTitle('Offers');
 
        $offersData = $this->getOffers('EXPORT');
        $offertList = $offersData['list'];
        
        $headers = [];
 
        $headers []= 'PRODUCT NAME' ;
        $headers []= 'MODEL NO' ;
        $headers []= 'SELLER NAME' ;
        $headers []= 'MRP OF PRODUCT' ;
        $headers []= 'ONLINE PRICE' ;
        $headers []= 'OFFER PRICE' ;
        $headers []= 'LAST OFFER BY SELLER' ;
        $headers []= 'REQUEST STATUS' ;
        $headers []= 'OFFER STATUS' ;
        $headers []= 'DELIVERY REASON FAILURE' ;
        $headers []= 'CREATED AT' ;
 
        $offerSheet->fromArray($headers, ' ', 'A1');
        $offerSheet->fromArray($offertList, ' ','A2');


        //Headr row height
        $offerSheet->getRowDimension('1')->setRowHeight(20);

        //Format header row
        FormatPhpExcel::format_header_row($offerSheet, array(
            'background_color'=>'FFFF00',
            'border_color'=>'000000',
            'font_size'=>'9',
            'font_color'=>'000000',
            'vertical_alignment'=>'VERTICAL_CENTER',
            'font-weight'=>'bold'
            ), '1'
        );
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="offers-export.xls"');
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

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
        $offertList = $this->getOffers('LIST');

        return view('admin.offerslist')->with('offerList',$offertList);
    }
    
    public function getOffers($type)
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
            
            if($type=='LIST')
            {
                $offertList[] =[
                        'id' => $productObj->getObjectId(),
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
                        'date'=>$offer->getCreatedAt()->format('Y-m-d H:i:s'),
                         ] ;  
            }
            
            
        }
        
        return $offertList;
    }
    
    public function offersExport()
    { 
        $excel = new PHPExcel();
        $offerSheet = $excel->getSheet(0);
		$offerSheet->setTitle('Offers');

        $offertList = $this->getOffers('EXPORT');
        
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
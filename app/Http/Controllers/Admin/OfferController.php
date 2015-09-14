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
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $displayLimit = config('constants.page_limit');
        $offersData = $this->getOffers('LIST',$page ,$displayLimit);
        $offertList = $offersData['list'];
        $numOfPages = $offersData['numOfPages'];
        $page = $offersData['page'];

        return view('admin.offerslist')->with('offerList',$offertList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','offers');
 
    }
    
    public function getOffers($type,$page ,$displayLimit)
    {  
        $numOfPages = 0;
        
        $offers = new ParseQuery("Offer");
        $offers->includeKey('seller');
        $offers->includeKey('request');
        $offers->includeKey('request');
        $offers->includeKey('product');
        $offers->includeKey('product.category');
        $offers->includeKey('price');

        $offers->descending("createdAt");
            //Pagination
 
        $offersCount = $offers->count();  
        $offers->limit($displayLimit);
        $offers->skip($page * $displayLimit);
        
        $numOfPages = ceil($offersCount/$displayLimit);
        $offersData = $offers->find(); 
       
        $offertList = [];
        
        foreach($offersData as $offer)
        {
            $requestObj= $offer->get("request");
            $productObj = $offer->get('product');
            $productCategoryObj = $productObj->get('category');
            $priceObj = $offer->get('price');  
            $requestId  = $requestObj->getObjectId(); 
            $productId  = $productObj->getObjectId();
            $createdDate = convertToIST($offer->getCreatedAt()->format('d-m-Y H:i:s'));
            
            $autoBid =   ($offer->get('autoBid'))?"Yes":"No"; 
            if($type=='LIST')
            {
                $offertList[] =[
                        'id' => $offer->getObjectId(),
                        'requestId'=>$requestId,
                        'productName'=>$productObj->get("name"),
                        'category'=>$productCategoryObj->get("name"),
                        'modelNo'=>$productObj->get("model_number"),
                        'sellerName'=>$offer->get("seller")->get("displayName"),
                        'sellerId'=>$offer->get("seller")->getObjectId(),
                        'area'=>$offer->get("area"),
                        'mrpOfProduct'=>$productObj->get("mrp"),   
                        'offerPrice'=>$priceObj->get("value"),
                        'requestStatus'=>$requestObj->get("status"),
                        'offerStatus'=>$offer->get("status"),
                        'deliveryReasonFailure'=>($requestObj->get("failedDeliveryReason")!='')?$requestObj->get("failedDeliveryReason"):'N/A',
                        'date'=>$createdDate, 
                        'autoBid'=>$autoBid, 
                         ] ; 
            }
            else
            {
                $offertList[] =[
                        'productId'=>$productObj->getObjectId(),
                        'productName'=>$productObj->get("name"),
                        'categoryId'=>$productCategoryObj->getObjectId(),
                        'category'=>$productCategoryObj->get("name"),
                        'modelNo'=>$productObj->get("model_number"),
                        'sellerName'=>$offer->get("seller")->get("displayName"),
                        'mrpOfProduct'=>$productObj->get("mrp"),   
                        'offerPrice'=>$offer->get("offerPrice"),
                        'requestStatus'=>$requestObj->get("status"),
                        'offerStatus'=>$offer->get("status"),
                        'deliveryReasonFailure'=>($requestObj->get("failedDeliveryReason")!='')?$requestObj->get("failedDeliveryReason"):'N/A',
                        'date'=>$createdDate,
                        'autoBid'=>$autoBid,  
                         ] ;  
            }
            
           
          // echo $createdDate; 
        }
         
        $data['list']=$offertList;
        $data['numOfPages']=$numOfPages;
        $data['page']=$page;
        return $data;
        
    }
    
    /*public function offersExport()
    { 
        $excel = new PHPExcel();
        $offersSheet = $excel->getSheet(0);
        $offersSheet->setTitle('Request');

        $headers = [];
        
        $headers []= 'PRODUCT ID' ;
        $headers []= 'PRODUCT NAME' ;
        $headers []= 'CATEGORY ID' ;
        $headers []= 'CATEGORY NAME' ;
        $headers []= 'MODEL NO' ;
        $headers []= 'SELLER NAME' ;
        $headers []= 'MRP OF PRODUCT' ;
        $headers []= 'OFFER PRICE' ;
        $headers []= 'REQUEST STATUS' ;
        $headers []= 'OFFER STATUS' ;
        $headers []= 'DELIVERY REASON FAILURE' ;
        $headers []= 'CREATED AT' ;
        $headers []= 'Auto Bid' ;
 
        $offersSheet->fromArray($headers, ' ', 'A1');

        $page = 0; 
        $limit = 20;
        $offers =[];
        while (true) {
          
          $offersData = $this->getOffers('EXPORT',$page ,$limit); //dd($requestsData);
          
          if(empty($offersData['list']))
            break;

          $offers = array_merge($offers,$offersData['list']);   
         
          $page++; 
         
        }
 
        $offersSheet->fromArray($offers, ' ','A2',true);
        //Headr row height
        $offersSheet->getRowDimension('1')->setRowHeight(20);

        //Format header row
        FormatPhpExcel::format_header_row($offersSheet, array(
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
    }*/

    public function offersExport()
    { 
 
        $headers = [];
        
        $headers []= 'PRODUCT ID' ;
        $headers []= 'PRODUCT NAME' ;
        $headers []= 'CATEGORY ID' ;
        $headers []= 'CATEGORY NAME' ;
        $headers []= 'MODEL NO' ;
        $headers []= 'SELLER NAME' ;
        $headers []= 'MRP OF PRODUCT' ;
        $headers []= 'OFFER PRICE' ;
        $headers []= 'REQUEST STATUS' ;
        $headers []= 'OFFER STATUS' ;
        $headers []= 'DELIVERY REASON FAILURE' ;
        $headers []= 'CREATED AT' ;
        $headers []= 'Auto Bid' ;
 

        $page = 0; 
        $limit = 20;
        $offers =[];
        while (true) {
          
          $offersData = $this->getOffers('EXPORT',$page ,$limit); //dd($requestsData);
          
          if(empty($offersData['list']))
            break;

          $offers = array_merge($offers,$offersData['list']);   
         
          $page++; 
         
        }
 
        $filename = "offers-export.csv";
        $handle = fopen($filename, 'w+');
        fputcsv($handle, $headers);
        foreach ($offers as $offer) {
          fputcsv($handle, $offer);
        }
        fclose($handle);

        $headers = array(
        'Content-Type' => 'text/csv',
        );

        return response()->download($filename, 'offers-export.csv', $headers);
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

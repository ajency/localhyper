<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;
use \PHPExcel;
use App\Http\Helper\FormatPhpExcel;

class SmsVerifyController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
       
        $smsVerifyData = $this->getSmsVerify('LIST');
        
        $smsVerifyList = $smsVerifyData['list'];
        $numOfPages = $smsVerifyData['numOfPages'];
        $page = $smsVerifyData['page'];

        return view('admin.smsverifylist')->with('smsVerifyList',$smsVerifyList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages);
 
    }
    
    public function getSmsVerify($type)
    {
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $numOfPages = 0;
        
        $smsVerify = new ParseQuery("SMSVerify");
        
        if($type == 'LIST')
        {   //Pagination
            
            $displayLimit = config('constants.page_limit'); 
 
            $smsVerifyCount = $smsVerify->count();  
            $smsVerify->limit($displayLimit);
            $smsVerify->skip($page * $displayLimit);
            
            $numOfPages = ceil($smsVerifyCount/$displayLimit);
        }
        
        $smsVerifyData = $smsVerify->find();   
        $smsVerifyList =[];
        
        foreach($smsVerifyData as $data)
        {  
 
            if($type=='LIST')
            {
               $smsVerifyList[]= [  'id' => $data->getObjectId(),
                                  'name' => $data->get("displayName"),
                                  'userType' => $data->get("userType"),
                                  'phone' => $data->get("phone"),
                                  'verificationCode' => $data->get("verificationCode"),
                                  'attempts' => $data->get("attempts"),    
                                  'updatedAt' => $data->getUpdatedAt()->format('d-m-Y'),    
                              ];
            }
            else
            {
                $smsVerifyList[]= [  
                                  'name' => $data->get("displayName"),
                                  'userType' => $data->get("userType"),
                                  'phone' => $data->get("phone"),
                                  'verificationCode' => $data->get("verificationCode"),
                                  'attempts' => $data->get("attempts"),    
                                  'updatedAt' => $data->getUpdatedAt()->format('d-m-Y'),    
                              ]; 
            }
             
        }
        
        $data =[];
        $data['list']=$smsVerifyList;
        $data['numOfPages']=$numOfPages;
        $data['page']=$page;
        
        return $data;
    }
    
    public function smsVerifyExport()
    { 
        $excel = new PHPExcel();
        $requestSheet = $excel->getSheet(0);
		$requestSheet->setTitle('SMS Verify');
        
        
        $requestList = $this->getSmsVerify('EXPORT');
        $headers = [];
 
        $headers []= 'NAME' ;
        $headers []= 'USER TYPE' ;
        $headers []= 'PHONE' ;
        $headers []= 'VERIFICATION CODE' ;
        $headers []= 'ATTEMPT' ;
        $headers []= 'UPDATE AT' ;

        										

        $requestSheet->fromArray($headers, ' ', 'A1');
        $requestSheet->fromArray($requestList, ' ','A2');


        //Headr row height
        $requestSheet->getRowDimension('1')->setRowHeight(20);

        //Format header row
        FormatPhpExcel::format_header_row($requestSheet, array(
            'background_color'=>'FFFF00',
            'border_color'=>'000000',
            'font_size'=>'9',
            'font_color'=>'000000',
            'vertical_alignment'=>'VERTICAL_CENTER',
            'font-weight'=>'bold'
            ), '1'
        );
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="sms-verify-export.xls"');
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

<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Admin\category\CategoryController;
use \PHPExcel;
use Parse\ParseObject;
use Parse\ParseQuery;
use \Session;
use \Input;

class AttributeController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        //
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
    
    public function bulkImport()
    {
        $parentCategories= CategoryController::getParentCategories();  
        return view('admin.attributeimport')->with('parentCategories', $parentCategories);

    }
    
    public function exportAttributes($catId,$filterable)
    {  
        $attributeData = $this->exportAttributeData($catId);  //dd($attributeData);
    
        $ea = new PHPExcel(); // ea is short for Excel Application
        $ea->getProperties()
                           ->setCreator('Prajay Verenkar')
                           ->setTitle('PHPExcel Attributes')
                           ->setLastModifiedBy('Prajay Verenkar')
                           ->setDescription('A demo to show how to use PHPExcel to manipulate an Excel file')
                           ->setSubject('PHP Excel manipulation')
                           ->setKeywords('excel php office phpexcel lakers')
                           ->setCategory('programming');
        
        $ews = $ea->getSheet(0);
        $ews->setTitle('Attributes');
        
        $headers []= 'Filterable' ;
        $headers []= 'objectId' ;
        $headers []= 'name' ;
        $headers []= 'group' ;
        $headers []= 'unit' ;
        $headers []= 'display_type';
 
        $ews->fromArray($headers, ' ', 'A1');
        $ews->fromArray([$filterable], ' ', 'A2');
        $ea->getActiveSheet()->getColumnDimension('A')->setVisible(false);
 
        $ews->fromArray($attributeData, ' ','B2');
 
        $lastColumn = $ews->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $ews->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $ews->getStyle($header)->applyFromArray($style);
        
         
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="attributes-export.xls"');
        header('Cache-Control: max-age=0');
        // If you're serving to IE 9, then the following may be needed
        header('Cache-Control: max-age=1');
        // If you're serving to IE over SSL, then the following may be needed
        header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
        header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); // always modified
        header ('Cache-Control: cache, must-revalidate'); // HTTP/1.1
        header ('Pragma: public'); // HTTP/1.0
        $objWriter = \PHPExcel_IOFactory::createWriter($ea, 'Excel5');
        $objWriter->save('php://output'); 
    }
    
    public function importAttributes()
    {
        $categoryId = '';
        $inputFileName = 'C:\Users\admin\Desktop\attributes-export.xls';
        $inputFileType = \PHPExcel_IOFactory::identify($inputFileName);
        $objReader = \PHPExcel_IOFactory::createReader($inputFileType);
        $objPHPExcel = $objReader->load($inputFileName);
        
        //  Get worksheet dimensions
        $sheet = $objPHPExcel->getSheet(0); 
        $highestRow = $sheet->getHighestRow(); 
        $highestColumn = $sheet->getHighestColumn();
        
        $headingsArray = $sheet->rangeToArray('A1:'.$highestColumn.'1',null, true, true, true);
        $headingsArray = $headingsArray[1];
        
        $r = -1;
        $namedDataArray = $filterable =array();
        for ($row = 2; $row <= $highestRow; ++$row) {
            $dataRow = $sheet->rangeToArray('A'.$row.':'.$highestColumn.$row,null, true, true, true);
             
                ++$r;
                foreach($headingsArray as $columnKey => $columnHeading) {
                    if($columnHeading!='Filterable')
                        $namedDataArray[$r][$columnHeading] = $dataRow[$row][$columnKey];
                    else
                        $filterable[]=$dataRow[$row][$columnKey];
                 }
        }
        $data = ['attributes' => $namedDataArray,
                 'categoryId' => $categoryId,
                 'isFilterable' => $filterable[0],
                ];
        
       
        return $data;
       
        
    }
    
    public function exportAttributeValues()
    {
         $attributeData = $this->exportAttributeValueData(0);  
    
        $ea = new PHPExcel(); // ea is short for Excel Application
        $ea->getProperties()
                           ->setCreator('Prajay Verenkar')
                           ->setTitle('PHPExcel Demo')
                           ->setLastModifiedBy('Prajay Verenkar')
                           ->setDescription('A demo to show how to use PHPExcel to manipulate an Excel file')
                           ->setSubject('PHP Excel manipulation')
                           ->setKeywords('excel php office phpexcel lakers')
                           ->setCategory('programming');
        
        $ews = $ea->getSheet(0);
        $ews->setTitle('Index');
               
        $headers = $data = $headerBlock= $headerFlag = [];

        foreach($attributeData['ATTRIBUTES'] as $attributeValues)
        {
            $attributeId =$attributeValues['ATTRIBUTE_ID'];
            if(!isset($headerFlag[$attributeId]))
            {   
                $headers[]=$attributeValues['ATTRIBUTE_NAME'];
                $headers[]='Attribute Id';
                $headerFlag[$attributeId]=$attributeId;
            }

            $headerBlock[$attributeId][] = [$attributeValues['ATTRIBUTE_VALUE'],$attributeValues['ATTRIBUTE_VALUE_ID']];  
        }
       
       $headers[]='Brand';
       $headers[]='Brand Id';
        
       $headers[]='Test';
       $headers[]='Test Id';     
        /*
           generate header
        */
       $ews->fromArray($headers, ' ', 'A1');
      
 
        $column = 'A';
        foreach($headerBlock as $headerBlockData)
        {
            $ews->fromArray($headerBlockData, ' ', $column.'2');
            
            //hide column
            $hidecolumn = $this->getNextCell($column,'1');
            $ea->getActiveSheet()->getColumnDimension($hidecolumn)->setVisible(false);
            
            $column = $this->getNextCell($column,'2');
            
    
        }
 
        $ews->fromArray($attributeData['BRAND'], ' ', $column.'2');
        $hidecolumn = $this->getNextCell($column,'1');
        $ea->getActiveSheet()->getColumnDimension($hidecolumn)->setVisible(false);
    
 
        $lastColumn = $ews->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $ews->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $ews->getStyle($header)->applyFromArray($style);
        
         
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="01simple.xls"');
        header('Cache-Control: max-age=0');
        // If you're serving to IE 9, then the following may be needed
        header('Cache-Control: max-age=1');
        // If you're serving to IE over SSL, then the following may be needed
        header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
        header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); // always modified
        header ('Cache-Control: cache, must-revalidate'); // HTTP/1.1
        header ('Pragma: public'); // HTTP/1.0
        $objWriter = \PHPExcel_IOFactory::createWriter($ea, 'Excel5');
        $objWriter->save('php://output');
    
    }
    
    public function getNextCell($currentColumn,$adjustment)
    {
        $columnIndex = \PHPExcel_Cell::columnIndexFromString($currentColumn);
        $adjustedColumnIndex = $columnIndex + $adjustment;
        $adjustedColumn = \PHPExcel_Cell::stringFromColumnIndex($adjustedColumnIndex - 1);
        
        return $adjustedColumn;
    }
    
    public function exportAttributeData()
    {
        $data []=['ObjectId' => '1','Name'=> 'Type' ,'Group'=> 'A' ,'Unit'=> '1' ,'Display-Type'=> 'X1'];
        $data []=['ObjectId' => '2','Name'=> 'Color' ,'Group'=> 'B' ,'Unit'=> '2' ,'Display-Type'=> 'X2'];

        return $data;

    }
    
    public function exportAttributeValueData($categoryId)
    {
        $data =[];
        $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '1',
                                'ATTRIBUTE_NAME'=> 'Type',
                                'ATTRIBUTE_VALUE'=> 'Single Door',  
                                'ATTRIBUTE_VALUE_ID' => '1'];
                                
        $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '1',
                                'ATTRIBUTE_NAME'=> 'Type',
                                'ATTRIBUTE_VALUE'=> 'Double Door',  
                                'ATTRIBUTE_VALUE_ID' => '2'];
        
        $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
                                'ATTRIBUTE_NAME'=> 'Color',
                                'ATTRIBUTE_VALUE'=> 'Red',  
                                'ATTRIBUTE_VALUE_ID' => '1'];
                                
        $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
                                'ATTRIBUTE_NAME'=> 'Color',
                                'ATTRIBUTE_VALUE'=> 'Gray',  
                                'ATTRIBUTE_VALUE_ID' => '2'];
        
        $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
                                'ATTRIBUTE_NAME'=> 'Color',
                                'ATTRIBUTE_VALUE'=> 'Black',  
                                'ATTRIBUTE_VALUE_ID' => '3'];
                                
        $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
                                'ATTRIBUTE_NAME'=> 'Color',
                                'ATTRIBUTE_VALUE'=> 'Blue',  
                                'ATTRIBUTE_VALUE_ID' => '4'];
        
        $data ['BRAND'][] =['NAME' =>'Samsung','ID'  => '1'];
        $data ['BRAND'][] =['NAME' =>'Lg','ID'  => '2'];
        
        $data ['TEST'][] =['NAME' =>'test1','ID'  => '1'];
        $data ['TEST'][] =['NAME' =>'test2','ID'  => '2'];
   
        return $data;

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

    public static function parseAttributeImport($data){

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
        curl_setopt($ch, CURLOPT_HTTPHEADER, $header_array);                                                                       
                                                                                                                          

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

    public function getCategoryAttributes($categoryId){

      $categoryQuery = new ParseQuery("Category");
      $categoryQuery->equalTo("objectId",$categoryId);

      $categoryQuery->includeKey("filterable_attributes");
      $categoryQuery->includeKey("secondary_attributes");

      $categoryObject = $categoryQuery->first();

      $filterable_attributes = (is_null($categoryObject->get("filterable_attributes"))) ? array() : $categoryObject->get("filterable_attributes");
      $secondary_attributes =  (is_null($categoryObject->get("secondary_attributes"))) ? array() : $categoryObject->get("secondary_attributes");

      $attributes = array();
      foreach ($filterable_attributes as $filterable_attribute) {
        $attributes["filterable"][] = array(
                'id' =>$filterable_attribute->getObjectId(),
                'name' => $filterable_attribute->get('name'),
                'display_type' => $filterable_attribute->get('display_type'),
                'group' => $filterable_attribute->get('group'),
                'unit' => $filterable_attribute->get('unit'),
                );

      }

      foreach ($secondary_attributes as $secondary_attribute) {
        $attributes["secondary"][] = array(
                'id' =>$secondary_attribute->getObjectId(),
                'name' => $secondary_attribute->get('name'),
                'display_type' => $secondary_attribute->get('display_type'),
                'group' => $secondary_attribute->get('group'),
                'unit' => $secondary_attribute->get('unit'),
                );

      }

      return $attributes;
    }       
}

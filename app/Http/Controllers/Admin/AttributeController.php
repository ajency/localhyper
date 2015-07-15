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
    

    public function exportAttributes($catId)
    {  
        $attributes = $this->getCategoryAttributes($catId); 


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
        
        $headers []= 'Config' ;
        $headers []= 'objectId' ;
        $headers []= 'name' ;
        $headers []= 'group' ;
        $headers []= 'unit' ;
        $headers []= 'is_filterable';
        $headers []= 'is_primary';
 
        $ews->fromArray($headers, ' ', 'A1');
        $ews->fromArray([$catId], ' ', 'A2');

        $ea->getActiveSheet()->getColumnDimension('A')->setVisible(false);
 
        $ews->fromArray($attributes, ' ','B2');
 
        $lastColumn = $ews->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $ews->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $ews->getStyle($header)->applyFromArray($style);
        
        //*** SHEET 2 BRANDS
        $brands = $this->getCategoryBrands($catId);
        foreach($brands as $key=> $brand)
        {
            $brand["image"] = $brand["image"]["src"];
            $brands[$key] = $brand;
            
        }

        $headers = [];
        
        $ews2 = new \PHPExcel_Worksheet($ea, 'Brand');
        $ea->addSheet($ews2, 0);
        $ews2->setTitle('Brand');
        
        $headers []= 'Id' ;
        $headers []= 'Name' ;
        $headers []= 'Image' ;

 
        $ews2->fromArray($headers, ' ', 'A1');
        $ews2->fromArray($brands, ' ','A2');
 
        $lastColumn = $ews2->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $ews2->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $ews2->getStyle($header)->applyFromArray($style);
        
        
        
         
        
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
    
    public function importMasterData(Request $request)
    {
        $data = [];
        $attribute_file = $request->file('attribute_file')->getRealPath();
        if ($request->hasFile('attribute_file'))
        {
            $inputFileType = \PHPExcel_IOFactory::identify($attribute_file);
            $objReader = \PHPExcel_IOFactory::createReader($inputFileType);
            $objPHPExcel = $objReader->load($attribute_file);
            $sheetNames = $objPHPExcel->getSheetNames();
            //  Get worksheet dimensions
            for($i=0; $i<$objPHPExcel->getSheetCount() ;$i++)
            {
                $sheet = $objPHPExcel->getSheet($i);
                $sheetTitle = $sheetNames[$i];
                if($sheetTitle=='Brands')
                    $this->importBrands($sheet);
                elseif($sheetTitle=='Attributes')
                    $this->importAttributes($sheet);
            }
 
            
        }
        return redirect("/admin/attribute/bulkimport");
        
       
        
    }
    
    public function importBrand($sheet){
        /*$highestRow = $sheet->getHighestRow(); 
        $highestColumn = $sheet->getHighestColumn();

        $headingsArray = $sheet->rangeToArray('A1:'.$highestColumn.'1',null, true, true, true);
        $headingsArray = $headingsArray[1];

        $r = -1;
        $namedDataArray =array();
        for ($row = 2; $row <= $highestRow; ++$row) {
            $dataRow = $sheet->rangeToArray('A'.$row.':'.$highestColumn.$row,null, true, true, true);

                ++$r;
                foreach($headingsArray as $columnKey => $columnHeading) {
                        $namedDataArray[$r][$columnHeading] = $dataRow[$row][$columnKey];
                  }
        }

        $this->parseBrandImport($nonFilterableAttribute);*/
        
        return true;
    }
    
    public function importAttributes($sheet)
    {
        $highestRow = $sheet->getHighestRow(); 
        $highestColumn = $sheet->getHighestColumn();

        $headingsArray = $sheet->rangeToArray('A1:'.$highestColumn.'1',null, true, true, true);
        $headingsArray = $headingsArray[1];

        $r = -1;
        $namedDataArray = $config =array();
        for ($row = 2; $row <= $highestRow; ++$row) {
            $dataRow = $sheet->rangeToArray('A'.$row.':'.$highestColumn.$row,null, true, true, true);

                ++$r;
                foreach($headingsArray as $columnKey => $columnHeading) {
                    if($columnHeading!='Config')
                        $namedDataArray[$r][$columnHeading] = $dataRow[$row][$columnKey];
                    else
                        $config[]=$dataRow[$row][$columnKey];
                 }
        }
        
        $filterableAttribute= $nonFilterableAttribute= [];
        foreach($namedDataArray as $attributeData)
        {  
            $is_filterable = $attributeData['is_filterable']; 
            unset($attributeData['is_filterable']);
            if($is_filterable == 'yes')
              $filterableAttribute[]= $attributeData;
            else
               $nonFilterableAttribute[]= $attributeData; 
        }

        $filterableData =['attributes' => $filterableAttribute,
                         'categoryId' => $config[0],
                          'isFilterable' => true,
                        ]; 
        $this->parseAttributeImport($filterableData);

        $nonFilterableAttribute =['attributes' => $nonFilterableAttribute,
                         'categoryId' => $config[0],
                          'isFilterable' => false,
                        ]; 
        
        $this->parseAttributeImport($nonFilterableAttribute);
        
        return true;
    
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

    public function parseAttributeImport($data){

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
                  'categoryId' => 'NTraUMINob',
                  'isFilterable' => false,
                );

       
        $functionName = "attributeImport";

        $result = AttributeController::makeParseCurlRequest($functionName,$data); 

        return $result;

   
    
    } 

    public function getCategoryAttributes($categoryId){ 

      $categoryQuery = new ParseQuery("Category");
      $categoryQuery->equalTo("objectId",$categoryId);

      $categoryQuery->includeKey("filterable_attributes");
      $categoryQuery->includeKey("secondary_attributes");
      $categoryQuery->includeKey("primary_attributes");

      $categoryObject = $categoryQuery->first();

      $filterable_attributes = (is_null($categoryObject->get("filterable_attributes"))) ? array() : $categoryObject->get("filterable_attributes");
      $secondary_attributes =  (is_null($categoryObject->get("secondary_attributes"))) ? array() : $categoryObject->get("secondary_attributes");
      $primary_attributes = (is_null($categoryObject->get("primary_attributes"))) ? array() : $categoryObject->get("primary_attributes");

      $attributes = $primaryattributes = array();
      
      foreach ($primary_attributes as $primary_attribute) {
        $primaryattributes[] = $primary_attribute->getObjectId();

      }    
        
        
      foreach ($filterable_attributes as $filterable_attribute) {
        $attributes[] = array(
                'id' =>$filterable_attribute->getObjectId(),
                'name' => $filterable_attribute->get('name'),  
                'group' => $filterable_attribute->get('group'),
                'unit' => $filterable_attribute->get('unit'),
                'filterable' => 'yes',
                'primary' => (in_array($filterable_attribute->getObjectId(),$primaryattributes))?'yes':'no',
                );

      }

      foreach ($secondary_attributes as $secondary_attribute) {
        $attributes[] = array(
                'id' =>$secondary_attribute->getObjectId(),
                'name' => $secondary_attribute->get('name'),
                'group' => $secondary_attribute->get('group'),
                'unit' => $secondary_attribute->get('unit'),
                'filterable' => 'no',
                'primary' => (in_array($filterable_attribute->getObjectId(),$primaryattributes))?'yes':'no',
                );

      }


      return $attributes;
    }   

    public function getCategoryBrands($categoryId){
      
      $categoryQuery = new ParseQuery("Category");
      $categoryQuery->equalTo("objectId",$categoryId);
      $categoryQuery->includeKey("supported_brands",$categoryId);

      $categoryObject = $categoryQuery->first();

      $supported_brands = $categoryObject->get("supported_brands");

      $brands = array();
      
      foreach ($supported_brands as $supported_brand) {
        $brands[] = array(
                'id' =>$supported_brand->getObjectId(),
                'name' => $supported_brand->get('name'),
                'image' => $supported_brand->get('image'),
                );

      }

      return $brands;


    } 

    public static function makeParseCurlRequest($functionName,$data,$parseFunctType="functions"){
      
      $app_id = config('constants.parse_sdk.app_id');
      $rest_api_key = config('constants.parse_sdk.rest_api_key');
      $base_url = "https://api.parse.com/1";

      $post_url = $base_url."/".$parseFunctType."/".$functionName;

      $data_string = json_encode($data); 

      // -H "X-Parse-Application-Id: 837yxeNhLEJUXZ0ys2pxnxpmyjdrBnn7BcD0vMn7" \
      // -H "X-Parse-REST-API-Key: zdoU2CuhK5S1Dbi2WDb6Rcs4EgprFrrpiWx3fUBy" \
      // -H "Content-Type: application/json" \
      // -d '{}' \
      // https://api.parse.com/1/functions/hello       

      $header_array = array(                                                                          
        'X-Parse-Application-Id:' .$app_id ,                                                                                
        'X-Parse-REST-API-Key:' .$rest_api_key ,                                                                                
        'Content-Type: application/json'
        );

      $ch = curl_init();
      curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
      curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
      curl_setopt($ch, CURLOPT_URL,$post_url);
      curl_setopt($ch, CURLOPT_POST, 1);
      curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);                                                                  
      curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
      curl_setopt($ch, CURLOPT_HTTPHEADER, $header_array);                                                                       


      $curl_output = curl_exec($ch);


      if (curl_errno($ch)) {
        $result = array(
                  'success' => false, 
                  'message'=>curl_error($ch) , 
                  'status_code' => curl_getinfo($ch, CURLINFO_HTTP_CODE)
                  );
        
      }
      else{
      
        $result  = json_decode($curl_output);

      }

      curl_close($ch); 

      return $result;         
    }  
}

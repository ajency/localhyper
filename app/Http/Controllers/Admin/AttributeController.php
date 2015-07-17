<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Admin\category\CategoryController;
use App\Http\Controllers\Admin\BrandController;
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
    
    public function categoryConfiguration()
    {
        $parentCategories= CategoryController::getParentCategories();  
        return view('admin.attributeimport')->with('parentCategories', $parentCategories);

    }
    

    public function exportAttributes($catId)
    {  
        
        $excel = new PHPExcel(); // ea is short for Excel Application
        $excel->getProperties()
                           ->setCreator('Prajay Verenkar')
                           ->setTitle('PHPExcel Attributes')
                           ->setLastModifiedBy('Prajay Verenkar')
                           ->setDescription('A demo to show how to use PHPExcel to manipulate an Excel file')
                           ->setSubject('PHP Excel manipulation')
                           ->setKeywords('excel php office phpexcel lakers')
                           ->setCategory('programming');
        
        /***
        *
        * SHEET 1  ATTRIUTEVALUES
        *
        */
        $attributeValueSheet = $excel->getSheet(0);
        $attributeValueSheet->setTitle('AttributeValues');
        
        $categoryData = [
          'categoryId' => $catId,
          'filterableAttributes' => true,
          'secondaryAttributes' => true,
          ];
        $attributeValueData = $this->getCategoryAttributeValues($categoryData);//dd($attributeValueData);
        $headers = $data = $attributeValues= $headerFlag =[];

        foreach($attributeValueData['result'] as $attributeValue)
        {
            $attributeId =$attributeValue['attributeId'];
            if(!isset($headerFlag[$attributeId]))
            {   
                $headers[]=$attributeValue['attributeName']."(".$attributeId.")";
                $headers[]=$attributeValue['attributeName'].' Id';            
                $headerFlag[$attributeId]=$attributeId;
            }

            $attributeValues[$attributeId][] = [$attributeValue['value'],$attributeValue['valueId']];  
        }
       // dd($attributeValues);
       
 
        $attributeValueSheet->fromArray($headers, ' ', 'A1');
 
        $column = 'A';
        foreach($attributeValues as $attributeValue)
        {
            $attributeValueSheet->fromArray($attributeValue, ' ', $column.'2');
            
            //hide column
            $hidecolumn = $this->getNextCell($column,'1');
            $attributeValueSheet->getColumnDimension($hidecolumn)->setVisible(false);
            
            $column = $this->getNextCell($column,'2');
            
    
        }
 
        $lastColumn = $attributeValueSheet->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $attributeValueSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $attributeValueSheet->getStyle($header)->applyFromArray($style);
        $attributeValueSheet->protectCells($header, 'PHP');
        
        
        
        /***
        *
        * SHEET 2 ATTRIBUTE 
        *
        */
        $attributeSheet = new \PHPExcel_Worksheet($excel, 'Attributes');
        $excel->addSheet($attributeSheet, 0);
        $attributeSheet->setTitle('Attributes');
 
        $attributes = $this->getCategoryAttributes($catId);
        $categoryName = $attributes['categoryName'];
        
        $headers =[];
        $headers []= 'Config' ;
        $headers []= 'objectId' ;
        $headers []= 'name' ;
        $headers []= 'group' ;
        $headers []= 'unit' ;
        $headers []= 'is_filterable';
        $headers []= 'is_primary';
 
        $attributeSheet->fromArray($headers, ' ', 'A1');
        $attributeSheet->fromArray([$catId], ' ', 'A2');

        $attributeSheet->getColumnDimension('A')->setVisible(false);
        $attributeSheet->getColumnDimension('B')->setVisible(false);
 
        $attributeSheet->fromArray($attributes['attributes'], ' ','B2');
 
        $lastColumn = $attributeSheet->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $attributeSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $attributeSheet->getStyle($header)->applyFromArray($style);
        $attributeSheet->protectCells($header, 'PHP');
        
        
        
        
        /***
        *
        * SHEET 3 BRANDS 
        *
        */
        $brands = $this->getCategoryBrands($catId);
        foreach($brands as $key=> $brand)
        {
            $brand["image"] = $brand["image"]["src"];
            $brands[$key] = $brand;
    
        }

        $headers = [];
        
        $brandSheet = new \PHPExcel_Worksheet($excel, 'Brands');
        $excel->addSheet($brandSheet, 0);
        $brandSheet->setTitle('Brands');
        

        $headers []= 'Config' ;
        $headers []= 'objectId' ;
        $headers []= 'name' ;
        $headers []= 'imageUrl' ;
 
 
        $brandSheet->fromArray($headers, ' ', 'A1');
        $brandSheet->fromArray([$catId], ' ', 'A2');
        $brandSheet->getColumnDimension('A')->setVisible(false);
        $brandSheet->getColumnDimension('B')->setVisible(false);
        $brandSheet->fromArray($brands, ' ','B2');
 
        $lastColumn = $brandSheet->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $brandSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $brandSheet->getStyle($header)->applyFromArray($style);
        $brandSheet->protectCells($header, 'PHP');
        
               
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="'.$categoryName.'-export.xls"');
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
                elseif($sheetTitle=='AttributeValues')
                        $this->importAttributeValues($sheet);
            }
 
            
        }
        return redirect("/admin/attribute/bulkimport");
        
       
        
    }
    
    public function importBrands($sheet){
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
        $brands =['brands' => $namedDataArray,'categoryId' => $config[0]];  
        BrandController::parseBrandImport($brands);
        
        return true;
    }
    
    public function importAttributeValues($sheet){
        $highestRow = $sheet->getHighestRow(); 
        $highestColumn = $sheet->getHighestColumn();

        $headingsArray = $sheet->rangeToArray('A1:'.$highestColumn.'1',null, true, true, true);
        $headingsArray = $headingsArray[1];

        $r = -1;
        $namedDataArray = array();
        for ($row = 2; $row <= $highestRow; ++$row) {
            $dataRow = $sheet->rangeToArray('A'.$row.':'.$highestColumn.$row,null, true, true, true);

                ++$r;
                foreach($headingsArray as $columnKey => $columnHeading) {
                     $namedDataArray[$r][$columnHeading] = $dataRow[$row][$columnKey];
                 }
        }
        $attributeValues=$arr=[]; 
        foreach($namedDataArray as $namedData)
        {
            $i=1; 
            foreach($namedData as $key=>$value)
            { 
 
                if($i%2)
                {
                    if($value=='')
                        continue;
                    
                    $dataKey = explode("(",$key);
                    $dataattributeId = explode(")",$dataKey[1]); 
                    $attributeId = $dataattributeId[0];
                    $attributeValues['attributeValues'][] = ['objectId'=>'',
                                          'attributeId'=>$attributeId,
                                          'value'=>$value];
                }
                else
                {
                    $value = intval($value);
                    $attributeValueKey = count($attributeValues['attributeValues']);
                    $attributeValues['attributeValues'][($attributeValueKey-1)]['objectId']=$value;
                }
 
               $i++; 
            }
        }
         $this->parseAttributeValueImport($attributeValues);
        
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
    
    
    public function getNextCell($currentColumn,$adjustment)
    {
        $columnIndex = \PHPExcel_Cell::columnIndexFromString($currentColumn);
        $adjustedColumnIndex = $columnIndex + $adjustment;
        $adjustedColumn = \PHPExcel_Cell::stringFromColumnIndex($adjustedColumnIndex - 1);
        
        return $adjustedColumn;
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

   
        $functionName = "attributeImport";

        $result = AttributeController::makeParseCurlRequest($functionName,$data); 

        return $result;

    
    } 

    public function parseAttributeValueImport($data){
      $functionName = "attributeValueImport";

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

      $result = array(
                'categoryId' =>  $categoryId, 
                'categoryName' =>  $categoryObject->get("name"), 
                'attributes' =>  $attributes, 
                );
      
      return $result;
    }  

    public function getCategoryAttributeValues($categoryData){
      // $categoryData = array (
      //   'categoryId' => 'bOEz9mBh5Q',
      //   'filterableAttributes' => true,
      //   'secondaryAttributes' => true,
      //   );

      $functionName = "getAttribValueMapping";

      $resultjson = AttributeController::makeParseCurlRequest($functionName,$categoryData); 

      $response =  json_encode($resultjson);
       $response = json_decode($response,true);    
      
      return $response;
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
    
    // public function getCategoryAttributeValues($categoryId){

    //   $data =[];
    //     $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '1',
    //                             'ATTRIBUTE_NAME'=> 'Type',
    //                             'ATTRIBUTE_VALUE'=> 'Single Door',  
    //                             'ATTRIBUTE_VALUE_ID' => '1'];
                                
    //     $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '1',
    //                             'ATTRIBUTE_NAME'=> 'Type',
    //                             'ATTRIBUTE_VALUE'=> 'Double Door',  
    //                             'ATTRIBUTE_VALUE_ID' => '2'];
        
    //     $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
    //                             'ATTRIBUTE_NAME'=> 'Color',
    //                             'ATTRIBUTE_VALUE'=> 'Red',  
    //                             'ATTRIBUTE_VALUE_ID' => '1'];
                                
    //     $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
    //                             'ATTRIBUTE_NAME'=> 'Color',
    //                             'ATTRIBUTE_VALUE'=> 'Gray',  
    //                             'ATTRIBUTE_VALUE_ID' => '2'];
        
    //     $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
    //                             'ATTRIBUTE_NAME'=> 'Color',
    //                             'ATTRIBUTE_VALUE'=> 'Black',  
    //                             'ATTRIBUTE_VALUE_ID' => '3'];
                                
    //     $data ['ATTRIBUTES'][]=['ATTRIBUTE_ID' => '2',
    //                             'ATTRIBUTE_NAME'=> 'Color',
    //                             'ATTRIBUTE_VALUE'=> 'Blue',  
    //                             'ATTRIBUTE_VALUE_ID' => '4'];
        

    //     $data ['BRAND'][] =['NAME' =>'Samsung','ID'  => '1'];
    //     $data ['BRAND'][] =['NAME' =>'Lg','ID'  => '2'];
        
    //     $data ['TEST'][] =['NAME' =>'test1','ID'  => '1'];
    //     $data ['TEST'][] =['NAME' =>'test2','ID'  => '2'];
   
    //     return $data;

    // } 

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

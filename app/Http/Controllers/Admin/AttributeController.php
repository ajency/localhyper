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
				
				if(isset($attributeValueData['result']))
				{  
						foreach($attributeValueData['result']['attributeValues'] as $attributeValue)
						{
								$attributeId =$attributeValue['attributeId'];
								/*if(!isset($headerFlag[$attributeId]))
								{   
										$headers[]=$attributeValue['attributeName']."(".$attributeId.")";
										$headers[]=$attributeValue['attributeName'].' Id';            
										$headerFlag[$attributeId]=$attributeId;
								}*/
                                $headerFlag[$attributeId]=[];
								$attributeValues[$attributeId][] = [$attributeValue['value'],$attributeValue['valueId']];  
						}
                 
                        foreach($attributeValueData['result']['attributes'] as $attribute)
						{
                            $attributeId = $attribute['id'];
                            $headerFlag[$attributeId] = $attribute;            	
						}

						$attributes_label = [];
                    
                        foreach($headerFlag as $attribute)
						{
                            $attributeId = $attribute['id'];
                            $attributeName = $attribute['name'];
                            $headers[]=$attributeName."(".$attributeId.")";
                            $headers[]=$attributeName.' Id';
                            $attributes_label[] = $attributeName;
                            $attributes_label[] = '';            	
						}
                    
                        
				}
            
                
			 
				$attributeValueSheet->fromArray($attributes_label, ' ', 'A2');
				$attributeValueSheet->fromArray($headers, ' ', 'A3');
 
				$column = 'A';
				foreach($attributeValues as $attributeValue)
				{
						$attributeValueSheet->fromArray($attributeValue, ' ', $column.'4');
						$column = $this->getNextCell($column,'5');
				}




				$lastColumn = $attributeValueSheet->getHighestColumn();
				$header = 'a1:'.$lastColumn.'1';
				$attributeValueSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
				$style = array(
						'font' => array('bold' => true,),
						'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
						);
				$attributeValueSheet->getStyle($header)->applyFromArray($style);

				$attributeValueSheet->setCellValue('A1', "Attribute Values");


				//freeze pan
				$attributeValueSheet->getStyle('1:1')->getFont()->setBold(true);
				$attributeValueSheet->freezePane('A3');

				//Headr row height
				$attributeValueSheet->getRowDimension('1')->setRowHeight(18);
				$attributeValueSheet->getRowDimension('2')->setRowHeight(18);

				//Hide second row
				$attributeValueSheet->getRowDimension(3)->setVisible(false);

				//Format sheet
				self::formatSheet($attributeValueSheet, 'AttributesValues');

				//Merge cells
				$highest_column = $attributeValueSheet->getHighestColumn();
				$attributeValueSheet->mergeCells('A1:'.$highest_column.'1');

				//Format header row
				self::format_header_row($attributeValueSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '1'
				);

				//Format header row
				self::format_header_row($attributeValueSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '2'
				);



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
				
				
				$headers = array(
					array('','',$categoryName),
					array ('Config', 'objectId', 'Attribute Name', 'Group', 'Unit', 'Is Filternable', 'Is Primary'),
					array('Config', 'objectId', 'name', 'group', 'unit', 'is_filterable', 'is_primary')
					);
 
				$attributeSheet->fromArray($headers, ' ', 'A1');
				$attributeSheet->fromArray([$catId], ' ', 'A4');

				$attributeSheet->getColumnDimension('A')->setVisible(false);
				$attributeSheet->getColumnDimension('B')->setVisible(false);
 
				$attributeSheet->fromArray($attributes['attributes'], ' ','B4');
 
				$lastColumn = $attributeSheet->getHighestColumn();
				$header = 'a1:'.$lastColumn.'1';
				$attributeSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
				$style = array(
						'font' => array('bold' => true,),
						'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
						);
				$attributeSheet->getStyle($header)->applyFromArray($style);
				$attributeSheet->protectCells($header, 'PHP');



				/*Code Added by robiul*/
				//freeze pan
				$attributeSheet->getStyle('1:1')->getFont()->setBold(true);
				$attributeSheet->freezePane('D3');

				//Headr row height
				$attributeSheet->getRowDimension('1')->setRowHeight(18);
				$attributeSheet->getRowDimension('2')->setRowHeight(18);

				//Merge cells
				$attributeSheet->mergeCells('C1:G1');

				//Hide third row
				$attributeSheet->getRowDimension(3)->setVisible(false);

				//Format sheet
				self::formatSheet($attributeSheet, 'Attributes');


				//Format header row
				self::format_header_row($attributeSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '1'
				);
				//Format header row
				self::format_header_row($attributeSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '2'
				);






				
				
				
				
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
				
				$labels = [];
				$labels []= 'Config' ;
				$labels []= 'objectId' ;
				$labels []= 'Brand Name' ;
				$labels []= 'Image URL' ;

				$headers []= 'Config' ;
				$headers []= 'objectId' ;
				$headers []= 'name' ;
				$headers []= 'imageUrl' ;
 
 
				$brandSheet->fromArray($labels, ' ', 'A1');
				$brandSheet->fromArray($headers, ' ', 'A2');
				$brandSheet->fromArray([$catId], ' ', 'A3');
				$brandSheet->getColumnDimension('A')->setVisible(false);
				$brandSheet->getColumnDimension('B')->setVisible(false);
				$brandSheet->fromArray($brands, ' ','B3');
 
				
				//Headr row height
				$brandSheet->getRowDimension('1')->setRowHeight(20);

				//freeze pan
				$brandSheet->getStyle('1:1')->getFont()->setBold(true);
				$brandSheet->freezePane('A2');

				//Hide second row
				$brandSheet->getRowDimension(2)->setVisible(false);

				//Format header row
				self::format_header_row($brandSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '1'
				);

				self::formatSheet($brandSheet, 'Brands');

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
				return redirect("/admin/attribute/categoryconfiguration");
				
			 
				
		}
		
		public function importBrands($sheet){
				$highestRow = $sheet->getHighestRow(); 
				$highestColumn = $sheet->getHighestColumn();

				$headingsArray = $sheet->rangeToArray('A2:'.$highestColumn.'2',null, true, true, true); 
				// dd($headingsArray);
				$headingsArray = $headingsArray[2];

				$r = -1;
				$namedDataArray = $config =array();

				$brandsArr = [];
				for ($row = 3; $row <= $highestRow; ++$row) {
						$dataRow = $sheet->rangeToArray('A'.$row.':'.$highestColumn.$row,null, true, true, true);

								++$r;
								foreach($headingsArray as $columnKey => $columnHeading) {

										 if($columnHeading!='Config'){
												
												$namedDataArray[$r][$columnHeading] = $dataRow[$row][$columnKey];
										 }
										else
												$config[]=$dataRow[$row][$columnKey];
									 
								 }
								 if(!(is_null(max($namedDataArray[$r])))){
									 $brandsArr[] = $namedDataArray[$r];

								 }
								 
				}
				
				$all_brands = BrandController::getAllParseBrands(); 

				$updated_brands = [];

				foreach ($brandsArr as $brand) {
					
					$brandExistingId = array_search(strtolower($brand['name']), $all_brands);
					
					// if $brand is present in $all_brands then update objecId for that $brand in brandsArr
					if($brandExistingId !== false){
						$brand['objectId'] = $brandExistingId;

					}

					$updated_brands[] = $brand;
				}

				$brands =['brands' => $updated_brands,'categoryId' => $config[0]]; 
				BrandController::parseBrandImport($brands);
				
				return true;
		}
		
		public function importAttributeValues($sheet){
				$highestRow = $sheet->getHighestRow(); 
				$highestColumn = $sheet->getHighestColumn();

				$headingsArray = $sheet->rangeToArray('A3:'.$highestColumn.'3',null, true, true, true);
				$headingsArray = $headingsArray[3];

				$r = -1;
				$namedDataArray = array();
				for ($row = 4; $row <= $highestRow; ++$row) {
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
						echo "<pre>";
						print_r($namedData);
						echo "</pre>";

						foreach($namedData as $key=>$value)
						{ 

								if($i%2)
								{
										if($value==''){
											$i++;
											continue;
										}
												
										
										$dataKey = explode("(",$key);

										$dataattributeId = explode(")",$dataKey[1]); 
										$attributeId = $dataattributeId[0];
										$attributeValues['attributeValues'][] = ['objectId'=>'',
																					'attributeId'=>$attributeId,
																					'value'=>$value];
								}
								else
								{
										$value = $value;
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

				$headingsArray = $sheet->rangeToArray('A3:'.$highestColumn.'3',null, true, true, true);
				$headingsArray = $headingsArray[3];

				$r = -1;
				$namedDataArray = $config =array();
				for ($row = 4; $row <= $highestRow; ++$row) {
						$dataRow = $sheet->rangeToArray('A'.$row.':'.$highestColumn.$row,null, true, true, true);

								++$r;
								foreach($headingsArray as $columnKey => $columnHeading) {
										if($columnHeading!='Config')
												$namedDataArray[$r][$columnHeading] = $dataRow[$row][$columnKey];
										else
												$config[]=$dataRow[$row][$columnKey];
								 }
				}
				
				$filterableAttribute= $nonFilterableAttribute= $primaryAttributes= [];
				foreach($namedDataArray as $attributeData)
				{  
						$is_filterable = $attributeData['is_filterable'];
						$is_primary = $attributeData['is_primary'];
						unset($attributeData['is_filterable']);
						unset($attributeData['is_primary']);
						
						if (!(is_null(max($attributeData)))) {
							if($is_primary == 'yes')
							{
								$primaryAttributes= $attributeData;
								continue;
							}
							
							if($is_filterable == 'yes')
								$filterableAttribute[]= $attributeData;
							else
								$nonFilterableAttribute[]= $attributeData; 
						}

				}
				
				// pass primary attributes in the last call and pass empty array in previous calls
				//filterable Attributes
				$filterableData =['attributes' => $filterableAttribute,
												 'categoryId' => $config[0],
													'isFilterable' => true,
													'primaryAttributeObj'=>array(),
												]; 
               
				$this->parseAttributeImport($filterableData);
				
				 //Non filterable Attributes
				$nonFilterableAttribute =['attributes' => $nonFilterableAttribute,
												 'categoryId' => $config[0],
												 'isFilterable' => false,
												 'primaryAttributeObj'=>$primaryAttributes,          
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

			// $data = array (
			//   'attributes' => 
			//   array (
			//     0 => 
			//     array (
			//       'objectId' => '',
			//       'name' => 'new attributex',
			//       'group' => 'general',
			//       'unit' => '',
			//       ),
			//     ),
			//   'categoryId' => 'vpEoQCuBoD',
			//   'isFilterable' => true,
			//   'primaryAttributeObj' => 
			//   array (
			//     'objectId' => '',
			//     'name' => 'new attributey',
			//     'group' => 'general',
			//     'unit' => 'inches',
			//     ),
			//   );

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
			$categoryQuery->includeKey("filterable_attributes.filterAttribute");
			$categoryQuery->includeKey("secondary_attributes");
			$categoryQuery->includeKey("primary_attributes");

			$categoryObject = $categoryQuery->first();

			$filterable_attributes = (is_null($categoryObject->get("filterable_attributes"))) ? array() : $categoryObject->get("filterable_attributes");
			$secondary_attributes =  (is_null($categoryObject->get("secondary_attributes"))) ? array() : $categoryObject->get("secondary_attributes");
			$primary_attributes = (is_null($categoryObject->get("primary_attributes"))) ? array() : $categoryObject->get("primary_attributes");

			$attributes = $primaryattributes = array();
			
			foreach ($primary_attributes as $primary_attribute) {
				if (!empty($primary_attribute)) {
					$primaryattributes[] = $primary_attribute->getObjectId();
				}

			}    
				
			foreach ($filterable_attributes as $filter) {

				if($filter==null)
						continue;
				
				$filterable_attribute = $filter->get("filterAttribute");
				
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
					if($secondary_attribute==null)
							continue;
					
				$attributes[] = array(
								'id' =>$secondary_attribute->getObjectId(),
								'name' => $secondary_attribute->get('name'),
								'group' => $secondary_attribute->get('group'),
								'unit' => $secondary_attribute->get('unit'),
								'filterable' => 'no',
								'primary' => (in_array($secondary_attribute->getObjectId(),$primaryattributes))?'yes':'no',
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
		
				if(!empty($supported_brands))    
				{
					foreach ($supported_brands as $supported_brand) {
						$brand = array(
										'id' =>$supported_brand->getObjectId(),
										'name' => $supported_brand->get('name'),
										'image' => $supported_brand->get('image'),
										);

						$brands[] = $brand;

					}
				}

			return $brands;


		} 
		

		public static function makeParseCurlRequest($functionName,$data,$parseFunctType="functions"){
			
			$app_id = config('constants.parse_sdk.app_id');
			$rest_api_key = config('constants.parse_sdk.rest_api_key');
			$master_key = config('constants.parse_sdk.master_key');
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
				'X-Parse-Master-Key:' .$master_key,  
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


			$curl_output = curl_exec($ch); //echo $curl_output;exit;


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
//dd($result);
			curl_close($ch); 

			return $result;         
		} 




public static function format_header_row($sheet, $style, $row){
	$lastColumn = $sheet->getHighestColumn();
	$lastColumn++;
	for ($column = 'A'; $column != $lastColumn; $column++) {

		self::cell_style($sheet, $column.$row, array(
			'background_color'=>$style['background_color'],
			'border_color'=>$style['border_color'],
			'font_size'=>$style['font_size'],
			'font_color'=>$style['font_color'],
			'vertical_alignment'=>$style['vertical_alignment'],
			'font-weight'=>$style['font-weight']
			)
		);
	}

}




public static function cell_style($sheet, $cell, $style){

	if (array_key_exists('font-weight', $style)) {
		$font_weight = $style['font-weight'];
	}else{
		$font_weight = false;
	}

	$sheet->getStyle($cell)->getFill()->applyFromArray(
		array(
			'type'       => \PHPExcel_Style_Fill::FILL_SOLID,
			'startcolor' => array('rgb' => $style['background_color']),
			)
		);


	$styleArray = array(
		'borders' => array(
			'outline' => array(
				'style' => \PHPExcel_Style_Border::BORDER_THIN,
				'color' => array('rgb' => $style['border_color']),
				),
			),
		);
	$sheet->getStyle($cell)->applyFromArray($styleArray);

	$sheet->getStyle($cell)->getFont()->setBold($font_weight)
	->setName('Verdana')
	->setSize($style['font_size'])
	->getColor()->setRGB($style['font_color']);

	if (array_key_exists('vertical_alignment', $style)) {
	if($style['vertical_alignment'] == 'VERTICAL_CENTER'){
		$sheet->getStyle($cell)->getAlignment()->setVertical(\PHPExcel_Style_Alignment::VERTICAL_CENTER);
	}
	}

	if (array_key_exists('horizontal_alignment', $style)) {
	if($style['horizontal_alignment'] == 'HORIZONTAL_CENTER'){
		$sheet->getStyle($cell)->getAlignment()->setHorizontal(\PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
	}	
	}

	

}







public static function single_cell_dropdown($sheet, $cell, $label, $options){
	
		$objValidation = $sheet->getCell($cell)->getDataValidation();
		$objValidation->setType( \PHPExcel_Cell_DataValidation::TYPE_LIST );
		$objValidation->setErrorStyle( \PHPExcel_Cell_DataValidation::STYLE_INFORMATION );
		$objValidation->setAllowBlank(false);
		$objValidation->setShowInputMessage(true);
		$objValidation->setShowErrorMessage(true);
		$objValidation->setShowDropDown(true);
		$objValidation->setErrorTitle('Input error');
		$objValidation->setError('Value is not in list.');
		$objValidation->setPromptTitle('Pick from list');
		$objValidation->setPrompt('Please pick a '.$label.' from the drop-down list.');
		$objValidation->setFormula1('"'.$options.'"');		
}










public static function formatSheet($sheet, $type){
	$lastColumn = $sheet->getHighestColumn();
	$lastColumn++;
	$data_count = $sheet->getHighestRow()+10;

	if($type == 'Attributes'){
		$head_row = 3;
		$record_starts = $head_row+1;	
	}else if($type == 'Brands'){
		$head_row = 2;
		$record_starts = $head_row+1;
	}else if($type == 'AttributesValues'){
		$head_row = 3;
		$record_starts = $head_row+1;
	}
	

	for ($column = 'A'; $column != $lastColumn; $column++) {
		$value = $sheet->getCell($column.$head_row)->getValue();


		if($type == 'AttributesValues'){
			$coIndex = \PHPExcel_Cell::columnIndexFromString($column);
			if ($coIndex % 2 == 0) {
				$sheet->getColumnDimension($column)->setVisible(false);
			}else{
				//$sheet->getColumnDimension($column)->setVisible(false);
			}
		}

		if($type == 'Brands'){
			if($value == 'imageUrl'){
				$sheet->getColumnDimension($column)->setWidth(50);
			}else{
				$sheet->getColumnDimension($column)->setAutoSize(true);
			}
		}else{
		$sheet->getColumnDimension($column)->setAutoSize(true);
		}

		for ($x = $record_starts; $x <= $data_count; $x++) {
			$cell = $column.$x;
			$cell_value = $sheet->getCell($cell)->getValue();

			//odd/even alternate coloring
			if($type == 'AttributesValues'){
				$colIndex = \PHPExcel_Cell::columnIndexFromString($column);
				$half = ceil($colIndex / 2);
				if ($colIndex % 2 && $half % 2) {
					self::cellBackgroundColor($sheet, $cell, 'FFFFFF');
				}else{
					self::cellBackgroundColor($sheet, $cell, 'FFF2CC');
				}
			}else{
				if ($x % 2 == 0) {
					self::cellBackgroundColor($sheet, $cell, 'FFFFFF');
				}else{
					self::cellBackgroundColor($sheet, $cell, 'FFF2CC');
				}
			}



			if($type == 'Attributes'){
				if($value == 'is_filterable' || $value == 'is_primary'){
				$label = 'value';
				$options = 'yes,no';
				self::single_cell_dropdown($sheet, $cell, $label, $options);
			}
			}

			

		}
	}
}





public static function cellBackgroundColor($sheet, $cell, $color){
$sheet->getStyle($cell)->getFill()->applyFromArray(
		array(
			'type'       => \PHPExcel_Style_Fill::FILL_SOLID,
			'startcolor' => array('rgb' => $color),
			)
		);
}






}

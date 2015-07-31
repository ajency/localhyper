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
use App\Http\Helper\FormatPhpExcel;

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

				//$excelFormat = new FormatPhpExcel();
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
				$attributeValueData = $this->getCategoryAttributeValues($categoryData, "attributeValues");

				$headers = $data = $attributeValues= $headerFlag =[];

				$attributes_label = [];

				// dd($attributeValueData['result']);
				
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
				FormatPhpExcel::formatSheet($attributeValueSheet, 'AttributesValues');

				//Merge cells
				$highest_column = $attributeValueSheet->getHighestColumn();
				$attributeValueSheet->mergeCells('A1:'.$highest_column.'1');

				//Format header row
				FormatPhpExcel::format_header_row($attributeValueSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '1'
				);

				//Format header row
				FormatPhpExcel::format_header_row($attributeValueSheet, array(
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
				// dd($attributes);
				$categoryName = $attributes['categoryName'];
				
				
				$headers = array(
					array('','',$categoryName),
					array ('Config', 'objectId', 'Attribute Name', 'Type', 'Group', 'Unit', 'Is Filternable', 'Is Primary'),
					array('Config', 'objectId', 'name', 'type', 'group', 'unit', 'is_filterable', 'is_primary')
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
				FormatPhpExcel::formatSheet($attributeSheet, 'Attributes');


				//Format header row
				FormatPhpExcel::format_header_row($attributeSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '1'
				);
				//Format header row
				FormatPhpExcel::format_header_row($attributeSheet, array(
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
				FormatPhpExcel::format_header_row($brandSheet, array(
					'background_color'=>'FFFF00',
					'border_color'=>'000000',
					'font_size'=>'9',
					'font_color'=>'000000',
					'vertical_alignment'=>'VERTICAL_CENTER',
					'font-weight'=>'bold'
					), '1'
				);

				FormatPhpExcel::formatSheet($brandSheet, 'Brands');

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
				
				// $highestColumn = $sheet->getHighestColumn();
				// since only 4 columns in brands sheet => highest column = D
				$highestColumn = 'D';

				// echo "Highest column <br/>";
				// echo $highestColumn;

				$headingsArray = $sheet->rangeToArray('A2:'.$highestColumn.'2',null, true, true, true); 
				
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

				// echo "<pre>";
				// print_r($updated_brands) ; 
				// echo "</pre>";				

				
				BrandController::parseBrandImport($brands);
				
				return true;
		}
		
		public function importAttributeValues($sheet){
				$highestRow = $sheet->getHighestRow(); 
				$highestColumn = $sheet->getHighestDataColumn();


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
				$attributeValues['attributeValues'] = [];

				foreach($namedDataArray as $namedData)
				{
						$i=1; 

						if (!(is_null(max($namedData)))) {

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

										// $dec = str_replace( ',', '', $value );

										// if( is_numeric( $dec ) ) {
										// 	$value = $dec;
										// }
											$value = $value;
											$attributeValueKey = count($attributeValues['attributeValues']);
											$attributeValues['attributeValues'][($attributeValueKey-1)]['objectId']=$value;
									}

	 
								 $i++; 
							}

						}

				}

				$this->parseAttributeValueImport($attributeValues);
				
				return true;
		}
		
		public function importAttributes($sheet)
		{
				$highestRow = $sheet->getHighestRow(); 
				// $highestColumn = $sheet->getHighestColumn();
				$highestColumn = 'H';

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
				$primaryIsFilterable = true ;
				
				foreach($namedDataArray as $attributeData)
				{  
						$is_filterable = $attributeData['is_filterable'];
						$is_primary = $attributeData['is_primary'];
						unset($attributeData['is_filterable']);
						unset($attributeData['is_primary']);
						
						if (!(is_null(max($attributeData)))) {
							
							// if($is_primary == 'yes' )
							// {
							// 	echo "<pre>";
							// 	echo "is primary <br/>";
							// 	print_r($attributeData);
							// 	echo "</pre>";								
							// 	$primaryAttributes= $attributeData;

							// 	if($is_filterable == "yes"){
							// 		$filterableAttribute[]= $attributeData;
							// 	}
							// 	else if(){

							// 	}
							// 	continue;
							// }
							
							if($is_filterable == 'yes'){
								// echo "<pre>";
								// echo "is filterable <br/>";
								// print_r($attributeData);
								// echo "</pre>";
								

								// if it is also primary then set it as primary
								if($is_primary == 'yes' ){
									$primaryAttributes= $attributeData;

									$primaryIsFilterable = true ;
								}
								else{
									$filterableAttribute[]= $attributeData;
								}
								
							}

							else{
								// echo "<pre>";
								// echo "is not filterable <br/>";
								// print_r($attributeData);
								// echo "</pre>";								
								
								if($is_primary == 'yes' ){
									$primaryAttributes= $attributeData;
									$primaryIsFilterable = false ; 
								}	
								else{
									$nonFilterableAttribute[]= $attributeData; 
								}							
							}
						}

				}

				
				
				// pass primary attributes in the last call and pass empty array in previous calls
				//filterable Attributes
				$primaryFilterableAttributeObj = ($primaryIsFilterable) ? $primaryAttributes : array() ;
				$filterableData =['attributes' => $filterableAttribute,
												 'categoryId' => $config[0],
													'isFilterable' => true,
													'primaryAttributeObj'=>$primaryFilterableAttributeObj,
												]; 
               	
				$this->parseAttributeImport($filterableData);


				
				$primaryNonFilterableAttributeObj = ($primaryIsFilterable) ? array() : $primaryAttributes ; 
				 //Non filterable Attributes
				$nonFilterableAttribute =['attributes' => $nonFilterableAttribute,
												 'categoryId' => $config[0],
												 'isFilterable' => false,
												 'primaryAttributeObj'=>$primaryNonFilterableAttributeObj,          
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
								'type' => $filterable_attribute->get('type'),  
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
								'type' => $secondary_attribute->get('type'),
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

		public function getCategoryAttributeValues($categoryData, $sheetType = "index"){
			// $categoryData = array (
			//   'categoryId' => 'bOEz9mBh5Q',
			//   'filterableAttributes' => true,
			//   'secondaryAttributes' => true,
			//   );

			$functionName = "getAttribValueMapping";

			$resultjson = AttributeController::makeParseCurlRequest($functionName,$categoryData); 

			$response =  json_encode($resultjson);
			$response = json_decode($response,true); 
			$final_result = [];
			$filteredAttrib = [];

			if($sheetType == "attributeValues") {
			  	
				foreach ($response["result"]["attributes"] as $attributeArr) {
					
					if ($attributeArr['type'] == "select") {
						$filteredAttrib[] = $attributeArr;
					}

 				}
 				$response["result"]["attributes"] = $filteredAttrib;
			
			}

			
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

			// dd($data_string);	

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





}

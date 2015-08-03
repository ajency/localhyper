<?php
namespace App\Http\Helper;


class FormatPhpExcel
{


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










	public static function formatSheet($sheet, $type,$attributesArr, $attributeSheet = false){
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
		}else if($type == 'Products'){
			$head_row = 2;
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
			}else if($type == 'Products'){
				$attributes_start_index = \PHPExcel_Cell::columnIndexFromString('K');
				$coIndex = \PHPExcel_Cell::columnIndexFromString($column);
				if($coIndex>=$attributes_start_index){
					if ($coIndex % 2 == 0) {
						$sheet->getColumnDimension($column)->setVisible(false);
					}else{
						//$sheet->getColumnDimension($column)->setVisible(false);
					}
				}
			}

			if($type == 'Brands'){
				if($value == 'imageUrl'){
					$sheet->getColumnDimension($column)->setWidth(50);
				}else{
					$sheet->getColumnDimension($column)->setAutoSize(true);
				}
			}else if($type == 'Products'){
				if($value == 'ProductName'){
					$sheet->getColumnDimension($column)->setWidth(30);
				}else if($value == 'Image'){
					$sheet->getColumnDimension($column)->setWidth(25);
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
					}else if($value == 'type'){
						$label = 'type';
						$options = 'select,text';
						self::single_cell_dropdown($sheet, $cell, $label, $options);
					}
				}else if($type == 'Products'){
					if($value == 'Brand'){
						$label = 'Brand';
						$at_column = self::get_column_by_attribute('Brand', $attributeSheet);
						$end_row = $at_column['count'];
						$formula = 'Index!$'.$at_column['column'].'$2:$'.$at_column['column'].'$'.$end_row;
						self::single_cell_dropdown_from_list($sheet, $cell, $label, $formula);

						$at_columnIndex = \PHPExcel_Cell::columnIndexFromString($at_column['column']);
						$at_nextColumn = \PHPExcel_Cell::stringFromColumnIndex($at_columnIndex);

						$columnIndex = \PHPExcel_Cell::columnIndexFromString($column);
						$nextColumn = \PHPExcel_Cell::stringFromColumnIndex($columnIndex);
						$next_cell = $nextColumn.$x;
						$vlookup_formula = '=VLOOKUP('.$cell.',Index!'.$at_column['column'].'2:'.$at_nextColumn.$end_row.',2,0)';
						$sheet->setCellValue($next_cell, $vlookup_formula);
					}else if( preg_match( '!\(([^\)]+)\)!', $value, $match ) ){
						$wrd = $match[1];

						$attributeId = $wrd;

						if(strlen($wrd) == 10){
							$label = $sheet->getCell($column.'1')->getValue();
							$at_column = self::get_column_by_attribute($label, $attributeSheet);
							$end_row = $at_column['count'];
							$formula = 'Index!$'.$at_column['column'].'$2:$'.$at_column['column'].'$'.$end_row;
							
							if ($attributesArr[$attributeId]['type'] == "select") {
								self::single_cell_dropdown_from_list($sheet, $cell, $label, $formula);
							}



							$at_columnIndex = \PHPExcel_Cell::columnIndexFromString($at_column['column']);
							$at_nextColumn = \PHPExcel_Cell::stringFromColumnIndex($at_columnIndex);

							$columnIndex = \PHPExcel_Cell::columnIndexFromString($column);
							$nextColumn = \PHPExcel_Cell::stringFromColumnIndex($columnIndex);
							$next_cell = $nextColumn.$x;
							$vlookup_formula = '=VLOOKUP('.$cell.',Index!'.$at_column['column'].'2:'.$at_nextColumn.$end_row.',2,0)';

							if ($attributesArr[$attributeId]['type'] == "select") {
								$sheet->setCellValue($next_cell, $vlookup_formula);
							}


						}
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

		$styleArray = array(
		'borders' => array(
			'outline' => array(
				'style' => \PHPExcel_Style_Border::BORDER_THIN,
				'color' => array('rgb' => 'DADCDD'),
				),
			),
		);
	$sheet->getStyle($cell)->applyFromArray($styleArray);
	}






	public static function get_column_by_attribute($attribute, $attributeSheet){
		$row = 1;
		$lastColumn = $attributeSheet->getHighestColumn();
		$lastColumn++;

		for ($column = 'A'; $column != $lastColumn; $column++) {

			$value = $attributeSheet->getCell($column.$row)->getValue();

			if($value == $attribute){
				$col = $column;
				break;
			}

		}

		$row_count = $attributeSheet->getHighestDataRow();
		$count = 1;

		for ($drow = 2; $drow != $row_count; $drow++ ){
			$dvalue = $attributeSheet->getCell($col.$drow)->getValue();

			if(empty($dvalue)){
				$count = $drow-1;
				break;
			}
		}

		return array('column'=>$col, 'count'=>$count);
	}





	public static function single_cell_dropdown_from_list($sheet, $cell, $label, $formula){

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
		$objValidation->setFormula1($formula);
	}





}
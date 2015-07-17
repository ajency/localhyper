<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Admin\AttributeController;
 
use \PHPExcel;
use Parse\ParseObject;
use Parse\ParseQuery;
use \Session;
use \Input;

class ProductController extends Controller
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
    
     public function exportProducts($catId)
    {  
        $attributeController = new AttributeController(); 
        
        $excel = new PHPExcel(); // ea is short for Excel Application
        $excel->getProperties()
                           ->setCreator('Prajay Verenkar')
                           ->setTitle('PHPExcel Attributes')
                           ->setLastModifiedBy('Prajay Verenkar')
                           ->setDescription('A demo to show how to use PHPExcel to manipulate an Excel file')
                           ->setSubject('PHP Excel manipulation')
                           ->setKeywords('excel php office phpexcel lakers')
                           ->setCategory('programming');
 
        
         
        $indexSheet = $excel->getSheet(0);
        $indexSheet->setTitle('Index');
        
        $brandIndexData =[];
        $brands = $attributeController->getCategoryBrands($catId);
        foreach($brands as $key=> $brand)
        {
            $brandIndexData[] = ['name'=>$brand["name"],'id'=>$brand["id"]]; 
        }
 
        $headers = [];
        $headers []= 'Config' ;
        $headers []= 'Brand' ;
        $headers []= 'Brand id' ;
         
        $categoryData = [
          'categoryId' => $catId,
          'filterableAttributes' => true,
          'secondaryAttributes' => true,
          ];
        $attributeValueData = $attributeController->getCategoryAttributeValues($categoryData); 
        $attributeValues= $headerFlag =$productHeader = [];

        foreach($attributeValueData['result'] as $attributeValue)
        {
            $attributeId =$attributeValue['attributeId'];
            if(!isset($headerFlag[$attributeId]))
            {   
                $headers[]=$attributeValue['attributeName'];
                $headers[]=$attributeValue['attributeName'].' Id';
                
                $productHeader[]=$attributeValue['attributeName'];
                $productHeader[]=$attributeValue['attributeName'].' Id';
                
                    
                $headerFlag[$attributeId]=$attributeId;
            }

            $attributeValues[$attributeId][] = [$attributeValue['value'],$attributeValue['valueId']];  
        } 
         
        
        $indexSheet->fromArray($headers, ' ', 'A1');
        $indexSheet->fromArray([$catId], ' ', 'A2');
        $indexSheet->getColumnDimension('A')->setVisible(false);
        $indexSheet->getColumnDimension('C')->setVisible(false);
        $indexSheet->fromArray($brandIndexData, ' ','B2');
        
        $column = 'D';
        foreach($attributeValues as $attributeValue)
        {
            $indexSheet->fromArray($attributeValue, ' ', $column.'2');
            
            //hide column
            $hidecolumn = $attributeController->getNextCell($column,'1');
            $indexSheet->getColumnDimension($hidecolumn)->setVisible(false);
            
            $column = $attributeController->getNextCell($column,'2');
            
    
        }
 
        $lastColumn = $indexSheet->getHighestColumn();
        $header = 'a1:'.$lastColumn.'1';
        $indexSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $indexSheet->getStyle($header)->applyFromArray($style);
        $indexSheet->getProtection()->setSheet(true);
         
         /***
         * PRODUCTS SHEET
         *
         */
         
        $productSheet = new \PHPExcel_Worksheet($excel, 'Products');
        $excel->addSheet($productSheet, 0);
        $productSheet->setTitle('Products');
        
        $products = $headers = [];

        $headers []= 'Config' ;
        $headers []= 'ProductID' ;
        $headers []= 'ProductName' ;
        $headers []= 'ModelNumber' ;
        $headers []= 'Image' ; 
        $headers []= 'Brand' ;  
        $headers []= 'BrandID' ; 
        $headers []= 'Group' ;  
         
        $headers = array_merge($headers,$productHeader);  
 
 
        $productSheet->fromArray($headers, ' ', 'A1');
        $productSheet->fromArray([$catId], ' ', 'A2');
        $productSheet->getColumnDimension('A')->setVisible(false);
        $productSheet->getColumnDimension('B')->setVisible(false);
        $productSheet->getColumnDimension('G')->setVisible(false); 
        
        $column = 'I';
        for($i=1; $i<=(count($productHeader)/2) ;$i++ )
        {
            //hide column
            $hidecolumn = $attributeController->getNextCell($column,'1');
            $productSheet->getColumnDimension($hidecolumn)->setVisible(false);
            $column = $attributeController->getNextCell($column,'2');
        }
         
 
        $lastColumn = $productSheet->getHighestColumn(); 
        $header = 'a1:'.$lastColumn.'1';
        $productSheet->getStyle($header)->getFill()->setFillType(\PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setARGB('00ffff00');
        $style = array(
            'font' => array('bold' => true,),
            'alignment' => array('horizontal' => \PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),
            );
        $productSheet->getStyle($header)->applyFromArray($style);
        $productSheet->protectCells($header, 'PHP');
        
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="products-export.xls"');
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
}

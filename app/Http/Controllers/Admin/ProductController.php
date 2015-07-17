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
        $attributeValues= $headerFlag =$productHeader = $productAttributeIds = [];

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
            $productAttributeIds []=$attributeId;
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
        
        $products = $productsData = $headers = [];

        $headers []= 'Config' ;
        $headers []= 'ProductID' ; 
        $headers []= 'ProductName' ;
        $headers []= 'ModelNumber' ;
        $headers []= 'Image' ; 
        $headers []= 'MRP' ; 
        $headers []= 'Popularity' ; 
        $headers []= 'Brand' ;  
        $headers []= 'BrandID' ; 
        $headers []= 'Group' ;
         
        /*$productsData['ProductID']=[]; 
        $productsData['ProductName']=[]; 
        $productsData['ModelNumber']=[]; 
        $productsData['Image']=[]; 
        $productsData['MRP']=[]; 
        $productsData['Brand']=[]; 
        $productsData['BrandID']=[]; 
        $productsData['Group']=[]; */
  
        $headers = array_merge($headers,$productHeader); 
        /*foreach ($headers as $header)
        {
            $productsData[$header]=[]; 
        }*/
 
        
        $productSheet->fromArray($headers, ' ', 'A1');
        $productSheet->fromArray([$catId], ' ', 'A2');
        $productSheet->getColumnDimension('A')->setVisible(false);
        $productSheet->getColumnDimension('B')->setVisible(false);
        $productSheet->getColumnDimension('G')->setVisible(false); 
 
        $column = 'I'; 
        for($i=0; $i<=(count($productHeader)/2) ;$i++ )
        {
 
            //hide column
            $hidecolumn = $attributeController->getNextCell($column,'1');
            $productSheet->getColumnDimension($hidecolumn)->setVisible(false);
            $column = $attributeController->getNextCell($column,'2');
        }
 
        //dd($productsData);
        $products = $this->getCategoryProducts($catId, 0, 20) ;dd($products);
 
        
        foreach($products as $key=> $product) 
        {
            $productsData[$key]=$product['objectId']; 
            $productsData[$key]=$product['name'];  
            $productsData[$key]=$product['model_number'];  
            $productsData[$key]=$product['images'][0]['src']; 
            $productsData[$key]=$product['mrp']; 
            $productsData[$key]=$product['brandName']; 
            $productsData[$key]=$product['brandId']; 
            $productsData[$key]=$product['group']; 
            
            foreach($product['attrs'] as $attribute)
            {
                $productsData[$key] = $attribute['attributeValue'];
                $productsData[$key] = $attribute['attributeValueId'];
            }
        }
        $productSheet->fromArray($productsData, ' ', 'C2');
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


    public function importProduct(Request $request)
    {
        $data = [];
        $product_file = $request->file('product_file')->getRealPath();
        if ($request->hasFile('product_file'))
        {
            $inputFileType = \PHPExcel_IOFactory::identify($product_file);
            $objReader = \PHPExcel_IOFactory::createReader($inputFileType);
            $objPHPExcel = $objReader->load($product_file);
            $sheetNames = $objPHPExcel->getSheetNames();
            //  Get worksheet dimensions
          
                $sheet = $objPHPExcel->getSheet(0);
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
            
            /****
            *  (ProductID ProductName ModelNumber Image mrp ,popularity Brand BrandID Group) = 9
            *
            // Attribute values not included
            ***/
            $countFixedData = 9;
            $dataCount = count($namedDataArray[0]);
            $attributeIdKeys =[];
            
            $i=$countFixedData;
            while($i<$dataCount)
            {
                $attributeIdKeys[] =($i + 1);
                $i= $i+2;
            }
           
            $products = [];
            foreach($namedDataArray as $data)
            {
                $indexedData = array_values($data);
                $attributeIds = [];
                foreach($attributeIdKeys as $key)
                {
                    $attributeIds[] = $indexedData[$key];
                }
        
                $products['category'] = $config[0];
                $products['id'] = $data['ProductID'];
                $products['name'] = $data['ProductName'];
                $products['model_number'] = $data['ModelNumber'];
                $products['images'] = ['src'=>$data['Image']];
                $products['attrs'] = $attributeIds;
                $products['mrp'] = $data['MRP'];
                $products['brand'] = $data['BrandID'];
                $products['popularity'] = $data['Popularity'];
                $products['group'] = $data['Group'];
            }
            
            
        }
        return redirect("/admin/attribute/bulkimport");

    }

    public function getCategoryProducts($categoryId, $page, $displayLimit){

        $productQuery = new ParseQuery("ProductItem");
        
        $innerCategoryQuery = new ParseQuery("Category");
        $innerCategoryQuery->equalTo("objectId",$categoryId);

        # query to get products matching the child category
        $productQuery->matchesQuery("category", $innerCategoryQuery);

        $productQuery->includeKey("brand");
        $productQuery->includeKey("primaryAttributes");
        $productQuery->includeKey("primaryAttributes.attribute");
        $productQuery->includeKey("attrs");
        $productQuery->includeKey("attrs.attribute");
      

        # pagination
        $productQuery->limit($displayLimit);
        $productQuery->skip($page * $displayLimit);

        $results = $productQuery->find();

        $products = [];

        foreach ($results as $result) {
            $attrs = [];
            $attrs = $result->get("attrs");

           
            $productAttributes  = [];

            foreach ($attrs as $attr) {
               $productAttribute = array(
                                    'attributeId' => $attr->get("attribute")->getObjectId() , 
                                    'attributeName' => $attr->get("attribute")->get("name") , 
                                    'attributeValueId' => $attr->getObjectId()  , 
                                    'attributeValue' => $attr->get("value")
                                    );

               $productAttributes[] = $productAttribute;
            }

            $product = array(
                        'objectId' => $result->getObjectId(), 
                        'name' => $result->get("name"), 
                        'brandId' => $result->get("brand")->getObjectId(), 
                        'brandName' => $result->get("brand")->get("name"),
                        'images' => $result->get("images"), 
                        'model_number' => $result->get("model_number"), 
                        'mrp' => $result->get("mrp"), 
                        'popularity' => $result->get("popularity"),
                        'attrs' => $productAttributes,
                        'group' => $result->get("group")
                        );
            $products[] = $product;
         } 
      
        return $products;
    } 
    

   public static function parseProductImport($data){

        $data = array (
          'products' => 
          array (
            0 => 
            array (
              'category' => 'bOEz9mBh5Q',
              'name' => 'Haier HRD-1905BR Direct-cool Single-door Refrigerator',
              'model_number' => 'B00NKYN6NQ',
              'description' => '',
              'images' => 
              array (
                0 => 
                array (
                  'src' => 'http://ecx.images-amazon.com/images/I/31hp6N9QLrL.jpg',
                  ),
                ),
              'attrs' => 
              array (
                0 => 'VYDUTNZDiS',
                1 => 'n8OSsrbl8I',
                2 => '6MC1FBqSHk',
                3 => 'xh6ETgpp7g',
                ),
              'mrp' => '9900',
              'brand' => 'dYRPINT23g',
              'popularity' => 2,
              'group' => 'fridge',
              ),
            ),
          );

        $functionName = "productImport";

        $result = AttributeController::makeParseCurlRequest($functionName,$data,"jobs"); 

        return $result;
    }
}

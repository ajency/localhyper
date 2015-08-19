<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;

use Aws\Laravel\AwsFacade as AWS;
use Aws\Laravel\AwsServiceProvider;
use Illuminate\Config\Repository;
use Illuminate\Foundation\Application;

use DB;
use File;
use Intervention\Image\ImageManagerStatic as Image;

class ProcessImageController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */

    public $productSizes;
    public $categorySizes;

    public function __construct()
    {
        $this->productSizes = $this->getSizes('product');
        $this->categorySizes = $this->getSizes('category');
    }




    public function index()
    {

    //get all pending images 
        $pending_images = DB::table('process_images')->where('status', 0)->get();

        if(!$pending_images){
            echo "<h3>No pending images found...</h3>";
            return;
        }

        //Create temporary folder if not exist
        if(!File::exists(public_path().'/tmp')) {
            File::makeDirectory(public_path().'/tmp', 0777);
        }

        foreach($pending_images as $pending){

            $images = unserialize($pending->images);
            $error = array();
            foreach($images as $key=>$value){

            //Resize and upload the image to amazon s3
                if (@getimagesize($value)) {
                    $this->processImage($value, $pending->object_type);
                }else{
                    $error[] = 1;
                }
                
            }

            //Change status when image processed successfully
            if(count($error)<=0){
            DB::table('process_images')
            ->where('id', $pending->id)
            ->update(['status' => 1]);
            }

        unset($error);
        }

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







    public function processImage($url, $object_type)
    {

        //Instantiate Amazon S3 client object
        $s3 = AWS::createClient('s3');

        $source = pathinfo($url);
        $filename = $source['filename'];
        $extension = $source['extension'];
        $basename = $source['basename'];
        
        //Temporary path to save images locally
        $destinationPath = public_path().'/tmp/';
        
        Image::make($url)->save($destinationPath.$basename);
          
        //Instantiate the image object from local copy
        $image = Image::make($destinationPath.$basename);

        if($object_type == "product"){
            $available_sizes = $this->productSizes; 
        }
        else{
            $available_sizes = $this->productSizes; 
        }
        

        foreach($this->productSizes as $size){
            $name =  $filename.$size['name'].'.'.$extension;
            $width = $size['width'];
            $height = $size['height'];

            //Resize the image to each size ref@ getSizes() and save temporarily
            $image->resize($width, $height, function ($constraint) {
                $constraint->aspectRatio();

                //make the image in actual size if the actual size is less than highest defined size
                //$constraint->upsize();
            })->save($destinationPath.$name);

        //Upload the resized image to amazon s3
            $s3->putObject(array(
                'Bucket'     => 'aj-shopoye',
                'Key'        => 'images-product/'.$name,
                'SourceFile' => $destinationPath.$name,
                'ACL'        => 'public-read',
                ));

        //Remove the local file once uploaded
            if (File::exists($destinationPath.$name))
            {
                File::delete($destinationPath.$name);
            }

        }

        //Remove the local original file once all sizes are generated and uploaded
        if (File::exists($destinationPath.$basename))
        {
            File::delete($destinationPath.$basename);
        }

    return true;
    }




    public function getSizes($type='products'){

        if($type == "category"){
            return  array(
                array('name'=>'-367x220', 'width'=>'367', 'height'=>'220', 'ratio'=>'5:3'),
                array('name'=>'-300x180', 'width'=>'300', 'height'=>'180', 'ratio'=>'5:3'),
                array('name'=>'-183x110', 'width'=>'183', 'height'=>'110', 'ratio'=>'5:3'),
                array('name'=>'-150x90', 'width'=>'150', 'height'=>'90', 'ratio'=>'5:3')
                );

        }
        else{
            return array(
                array('name'=>'-150x90', 'width'=>'150', 'height'=>'90', 'ratio'=>'5:3'),
                array('name'=>'-300x180', 'width'=>'300', 'height'=>'180', 'ratio'=>'5:3'),
                array('name'=>'-400x240', 'width'=>'400', 'height'=>'240', 'ratio'=>'5:3'),
                array('name'=>'-800x480', 'width'=>'800', 'height'=>'480', 'ratio'=>'5:3'),
                array('name'=>'-180x108', 'width'=>'180', 'height'=>'108', 'ratio'=>'5:3'),
                array('name'=>'-360x216', 'width'=>'360', 'height'=>'216', 'ratio'=>'5:3'),
                array('name'=>'-736x442', 'width'=>'736', 'height'=>'442', 'ratio'=>'5:3'),
                array('name'=>'-1000x600', 'width'=>'1000', 'height'=>'600', 'ratio'=>'5:3')
                );

        }

    }









}

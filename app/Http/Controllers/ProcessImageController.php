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


            $this->resizeImage($destinationPath.$basename, $destinationPath.$name, $width, $height);


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
                array('name'=>'-600x360', 'width'=>'600', 'height'=>'360', 'ratio'=>'5:3'),
                array('name'=>'-180x108', 'width'=>'180', 'height'=>'108', 'ratio'=>'5:3'),
                array('name'=>'-360x216', 'width'=>'360', 'height'=>'216', 'ratio'=>'5:3')
                );

        }

    }










    public function resizeImage($file, $destination, $w, $h) {
        list($source_width, $source_height, $source_type) = getimagesize($file);

        $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
        if ($ext == "jpg" || $ext == "jpeg") {
            $source_gdim=imagecreatefromjpeg($file);
        } elseif ($ext == "png") {
            $source_gdim=imagecreatefrompng($file);
        } elseif ($ext == "gif") {
            $source_gdim=imagecreatefromgif($file);
        } else {

            return;
        }

        if ($w && !$h) {
            $ratio = $w / $source_width;
            $temp_width = $w;
            $temp_height = $source_height * $ratio;

            $desired_gdim = imagecreatetruecolor($temp_width, $temp_height);
            imagecopyresampled(
                $desired_gdim,
                $source_gdim,
                0, 0,
                0, 0,
                $temp_width, $temp_height,
                $source_width, $source_height
                );
        } else {
            $source_aspect_ratio = $source_width / $source_height;
            $desired_aspect_ratio = $w / $h;

            if ($source_aspect_ratio > $desired_aspect_ratio) {

                $temp_height = $h;
                $temp_width = ( int ) ($h * $source_aspect_ratio);
            } else {

                $temp_width = $w;
                $temp_height = ( int ) ($w / $source_aspect_ratio);
            }



            $temp_gdim = imagecreatetruecolor($temp_width, $temp_height);
            imagecopyresampled(
                $temp_gdim,
                $source_gdim,
                0, 0,
                0, 0,
                $temp_width, $temp_height,
                $source_width, $source_height
                );



            $x0 = ($temp_width - $w) / 2;
            $y0 = ($temp_height - $h) / 2;
            $desired_gdim = imagecreatetruecolor($w, $h);
            imagecopy(
                $desired_gdim,
                $temp_gdim,
                0, 0,
                $x0, $y0,
                $w, $h
                );
        }

        if ($ext == "jpg" || $ext == "jpeg") {
            ImageJpeg($desired_gdim,$destination,100);
        } elseif ($ext == "png") {
            ImagePng($desired_gdim,$destination);
        } elseif ($ext == "gif") {
            ImageGif($desired_gdim,$destination);
        } else {
            return;
        }

        ImageDestroy ($desired_gdim);
    }









}

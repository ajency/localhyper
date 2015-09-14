<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Admin\AttributeController;
use Parse\ParseObject;
use Parse\ParseQuery;

class JobsController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $sellerQuery = new ParseQuery("_User");
        $sellerQuery->equalTo("userType", "seller");
        $sellerQuery->exists("autoBid");
        $sellerQuery->equalTo("autoBid", true);

        $autoBidSellers = $sellerQuery->find();

        
        
        foreach ($autoBidSellers as $autoBidSeller) {
            /** get requests that are:
                1. status = open
                2. createdAt is less than or equal to currentDate10MinutesAgo 
            **/
            $sellerId = $autoBidSeller->getObjectId();
            $openRequestsForSeller = $this->getNewOpenRequests($sellerId);

            $openBidRequests = $this->getAutoBiddableRequests($openRequestsForSeller);

            foreach ($openBidRequests as $openRequest) {

                // make offer for the request on behalf of the seller
                $offerData = [];
                $offerData["priceValue"] =  $openRequest["lastOfferPrice"];
                $offerData["deliveryTime"] = $openRequest["lastDeliveryTime"];

                $sellerId = $autoBidSeller->getObjectId();
                $requestId = $openRequest['id'];
                $result = $this->makeOffer( $sellerId, $requestId, $offerData );
            }
        }

    }
    public function getNewOpenRequests($sellerId){
        $newOpenRequestsData = array (
            "sellerId" => $sellerId,
            "city" =>  "default",
            "area" =>  "default",
            "sellerLocation" =>  "default",
            "sellerRadius" => "default",
            "categories"  =>  "default",
            "brands" =>  "default",
            "productMrp" =>  "default"
        );

        
        $functionName = "getNewRequests";

        $resultjson = AttributeController::makeParseCurlRequest($functionName,$newOpenRequestsData); 

        $response =  json_encode($resultjson);
        $response = json_decode($response,true); 

        return $response["result"]["requests"];

    }

    public function makeOffer($sellerId, $requestId, $offerData){
        $makeOfferData = array (
            "sellerId" => $sellerId,
            "requestId" =>  $requestId,
            "priceValue" =>  $offerData["priceValue"],
            "deliveryTime" =>  $offerData["deliveryTime"],
            "comments" =>  "",
            "status" => "open" ,
            "autoBid" => true
        );

        $functionName = "makeOffer";

        $resultjson = AttributeController::makeParseCurlRequest($functionName,$makeOfferData); 

        $response =  json_encode($resultjson);
        $response = json_decode($response,true); 

        return $response;

    }    

    public function getAutoBiddableRequests($openRequests){

        $biddableRequests = [];        

        foreach ($openRequests as $openRequest) {
            
            echo "<pre>";
            // current date in utc
            $current_date_utc = new \DateTime(null, new \DateTimeZone("UTC"));
            echo "<br/>";
            print_r($current_date_utc->format('d-m-Y h:i:s'));
            echo "<br/>";

            $requestcreatedAt = $openRequest['createdAt'];

            $requestCreatedDateObject = new \DateTime($requestcreatedAt['iso']);

            // print_r($requestCreatedDateObject);
            
            // add 10 minutes to request created date
            $mins10 = 10*60 ;
            // $createdPlus10Mins = $requestCreatedDateObject->add(new \DateInterval('PT'.$mins10.'S'));
            // $createdPlus10Mins = $requestCreatedDateObject->add(new \DateInterval('PT'.$mins10.'S'));
            print_r($requestCreatedDateObject->format('d-m-Y h:i:s'));echo "<br/>";
            print_r($openRequest["id"]);
            // check difference in minutes between current date and request created date object 
            $interval = $current_date_utc->diff($requestCreatedDateObject);

            $minutes = $interval->days * 24 * 60;
            $minutes += $interval->h * 60;
            $minutes += $interval->i;
            echo "<br/>";
            echo $minutes.' minutes';
            echo "</pre>";

            // if the difference is more than or equal to 10minutes then add this request to array of biddableRequests
            $minutes10 = 1;
            if ($minutes>=$minutes10) {
                // check is lastOfferPrice is not empty
                if($openRequest['lastOfferPrice']!= "") 
                    $biddableRequests[] = $openRequest;
            }
        }

        return $biddableRequests;
    }
}

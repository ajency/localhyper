<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/

Route::get( '/', 'WelcomeController@index' );

Route::get( 'process-image', 'ProcessImageController@index' );

/**
 * Auth and forgot password route
 */
Route::controllers( [
    'auth' => 'Auth\AuthController',
    'password' => 'Auth\PasswordController',
] );

/**
 * Backend Admin routes
 */
Route::group( ['prefix' => 'admin', 'middleware' => ['auth']], function() {
    Route::get( 'requests/requestexport', 'Admin\RequestController@requestExport' );
    Route::get( 'offers/offersexport', 'Admin\OfferController@offersExport' );
    Route::get( 'customer/customersexport', 'Admin\CustomerController@customersExport' );
    Route::get( 'seller/sellerexport', 'Admin\SellerController@sellersExport' );
    Route::get( 'smsverify/smsverifyexport', 'Admin\SmsVerifyController@smsVerifyExport' );
    
    Route::get( '/', 'Admin\AdminController@index' );
    Route::resource( 'customer', 'Admin\CustomerController' );
    Route::resource( 'seller', 'Admin\SellerController' );
    Route::resource( 'requests', 'Admin\RequestController' );
    Route::resource( 'offers', 'Admin\OfferController' );
    Route::resource( 'smsverify', 'Admin\SmsVerifyController' );
 
    Route::get( 'attribute/categoryconfiguration', 'Admin\AttributeController@categoryConfiguration' );
    Route::get( 'attribute/exportattributes/{categoryid}', 'Admin\AttributeController@exportAttributes' );

    // Route::resource( 'category', 'Admin\category\CategoryController' );
    Route::get( 'category/getparentcategories', 'Admin\category\CategoryController@getParentCategories' );
    Route::post( 'category/getchildcategories/{categoryid}', 'Admin\category\CategoryController@getChildCategory' );
    Route::post( 'attribute/importmasterdata', 'Admin\AttributeController@importMasterData' );
    Route::get( 'attribute/exportattributevalues', 'Admin\AttributeController@exportAttributeValues' );
    
     Route::get( 'product/exportproducts/{categoryid}', 'Admin\ProductController@exportProducts' );
     Route::get( 'product/exportproductonlineprice/{categoryid}', 'Admin\ProductController@exportProductOnlinePrice' );
    Route::post( 'product/importproducts', 'Admin\ProductController@importProduct' );
    Route::post( 'product/importproductprice', 'Admin\ProductController@importProductPrice' );

}); 

/**static pages*/
Route::get( '/customer-faqs', 'StaticPagesController@customerFaq' );
Route::get( '/seller-faqs', 'StaticPagesController@sellerFaq' );
 


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

Route::get('/', function () {
    return view('welcome');
});

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
    Route::get( '/', 'Admin\AdminController@index' );

    Route::get( 'attribute/bulkimport', 'Admin\AttributeController@bulkImport' );
    Route::get( 'attribute/exportattributes/{categoryid}/{filterable}', 'Admin\AttributeController@exportAttributes' );

    // Route::resource( 'category', 'Admin\category\CategoryController' );
    Route::get( 'attribute/importattributes', 'Admin\AttributeController@importAttributes' );
    Route::get( 'attribute/exportattributevalues', 'Admin\AttributeController@exportAttributeValues' );
    Route::get( 'attribute/getattributes', 'Admin\AttributeController@getCategoryAttributes' );
    Route::get( 'category/getparentcategories', 'Admin\category\CategoryController@getParentCategories' );
    Route::get( 'category/getchildcategories', 'Admin\category\CategoryController@getChildCategory' );
    
});    
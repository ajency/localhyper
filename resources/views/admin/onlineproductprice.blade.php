@extends('layouts.master') 
@section('content')
<div class="content">
    <div class="page-title m-l-5">
        <h3 class="inline"><span class="semi-bold">Online Product Price</span> Configuration</h3> <i class="fa fa-sitemap"></i>
    </div>
 
    <div class="grid simple vertical purple">
        <h4 class="grid-title"><span class="semi-bold">Follow the steps below to proceed</span></h4>
        <div class="grid-body">
            <!--select category-->
            <div class="row">
                <div class="col-sm-4">
                    <div class="form-group">
                        <label class="form-label">Department</label>
                        <select id="department" name="department" class="select2-container select2 form-control select2-container-active" onchange="getChildCategory(this);">
                            <option value="">Select Department</option>
                        </select>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="form-group">
                        <label class="form-label">Categories</label>
                        <select id="categories" name="category" class="select2-container select2 form-control select2-container-active">
                            <option value="">Select Category</option>

                        </select>
                    </div>
                </div>
                <div class="col-sm-4">
                    <button type="button" class="btn btn-info btn-cons m-t-25" onclick="getCategoryProducts(0);" ><i class="fa fa-send"></i> Go</button>
                </div>
            </div>
            <!--List products-->
          <table class="table table-bordered productPriceList" id="example2">
          <thead>
            <tr>
              <th>Product Name</th>
              <th>Model No</th>      
              <th>Amazon Price</th>   
              <th>Flipkart Price</th>    
              <th>Snap deal</th>
              <th></th>    
            </tr>
          </thead>
          <tbody>
          
          </tbody>
         </table>
 
            <div id="pagination"></div> 
            



        </div>
    </div>
</div>

<script>

$( document ).ready(function() {
   getCategories();
});
    
</script>
@endsection
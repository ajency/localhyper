@extends('layouts.master') @section('content')
<div class="content">
    <div class="page-title m-l-5">
        <h3 class="inline"><span class="semi-bold">Category</span> Configuration</h3> <i class="fa fa-sitemap"></i>
    </div>
    <div class="alert alert-info">
        <button class="close" data-dismiss="alert"></button>
        Info:&nbsp;Category Configuration will allow you to import/export data for product catalogue. </div>
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
                    <button type="button" class="btn btn-info btn-cons m-t-25" onclick="showAttibuteExport()"><i class="fa fa-send"></i> Go</button>
                </div>
            </div>
            <!--select category-->
            <div class="panel-group export_block hidden" id="accordion">
                <div class="panel panel-default">
                    <div class="panel-heading collapsed">
                        <h4 class="panel-title">
<a class="" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
<span class="semi-bold">Attributes :</span> Configure your brands, attributes and attribute values
</a>
</h4>
                    </div>
                    <div id="collapseOne" class="panel-collapse collapse in" style="height: auto;">
                        <div class="panel-body">
                            <h4>Configure your <span class="semi-bold">brands, attributes</span> and <span class="semi-bold">attribute values</span></h4>
                            <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Export</span></h4>

                            <a href="#" target="_blank" class="export_attributes">
                                <button type="button" class="btn btn-default btn-cons btn-small"><i class="fa fa-download"></i> Download Sheet</button>
                            </a>

                            <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Import</span></h4>
                            <form action="{{ url( 'admin/attribute/importmasterdata') }}" method="POST" enctype="multipart/form-data">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <input type="file" name="attribute_file" class="form-control" style="line-height: 19px;" />

                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="hidden" value="{{ csrf_token()}}" name="_token" />
                                        <button type="submit" class="btn btn-default btn-import"><i class="fa fa-upload"></i> Upload</button>
                                    </div>
                                </div>
                            </form>

                        </div>
                    </div>
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading collapsed">
                        <h4 class="panel-title">
<a class="collapsed" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
<span class="semi-bold">Products :</span> Configure your products
</a>
</h4>
                    </div>
                    <div id="collapseTwo" class="panel-collapse collapse" style="height: 0px;">
                        <div class="panel-body">
                            <h4>Configure your <span class="semi-bold">Products</span></h4>
                            <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Export</span></h4>
                            <a href="#" target="_blank" class="export_product">
                                <button type="button" class="btn btn-default btn-cons btn-small"><i class="fa fa-download"></i> Download Sheet</button>
                            </a>
                            <button style="float:right" data-category-id="" type="button" class="btn btn-default btn-cons btn-small update-search-keyword"><i class="fa "></i>Update Search Keyword</button>


                            <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Import</span></h4>
                            <form action="{{ url( 'admin/product/importproducts') }}" method="POST" enctype="multipart/form-data">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <input type="file" name="product_file" class="form-control" style="line-height: 19px;" />

                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="hidden" value="{{ csrf_token()}}" name="_token" />
                                        <button type="submit" class="btn btn-default btn-import"><i class="fa fa-upload"></i> Upload</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading collapsed">
                        <h4 class="panel-title">
<a class="collapsed" data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
<span class="semi-bold">Online Price :</span> Configure your products price
</a>
</h4>
                    </div>
                    <div id="collapseThree" class="panel-collapse collapse" style="height: 0px;">
                        <div class="panel-body">
                            <h4>Configure your <span class="semi-bold">Products price</span></h4>
                            <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Export</span></h4>

                            <a href="#" target="_blank" class="export_product_price">
                                <button type="button" class="btn btn-default btn-cons btn-small"><i class="fa fa-download"></i> Download Sheet</button>
                            </a>

                            <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Import</span></h4>
                            <form action="{{ url( 'admin/product/importproductprice') }}" method="POST" enctype="multipart/form-data">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <input type="file" name="product_price_file" class="form-control" style="line-height: 19px;" />

                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="hidden" value="{{ csrf_token()}}" name="_token" />
                                        <button type="submit" class="btn btn-default btn-import"><i class="fa fa-upload"></i> Upload</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>



        </div>
    </div>
</div>

<script>

$( document ).ready(function() {
   getCategories();
});
    
</script>
@endsection
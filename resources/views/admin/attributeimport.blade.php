@extends('layouts.master') 
@section('content')
<div class="content">
                        <div class="page-title m-l-5">
                            <h3 class="inline"><span class="semi-bold">Category</span> Map</h3> <i class="fa fa-sitemap"></i>
                        </div>
                        <div class="grid simple vertical purple">

                            <div class="grid-body">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <label class="form-label">Department</label>
                                            <select id="department" name="department" class="select2-container select2 form-control select2-container-active" onchange="getChildCategory(this);" >
                                                <option value="">Select Department</option>
                                                 @foreach($parentCategories as $parentCategory)
                                                    <option value="{{ $parentCategory['cat_id']}}">{{ $parentCategory['cat_name']}}</option>
                                                @endforeach
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
                                <div class="export_block hidden">
                                <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Export</span></h4>

                                    <a href="#" target="_blank" class="export_attributes"><button type="button" class="btn btn-default btn-cons btn-small"><i class="fa fa-download"></i> Download Sheet</button></a>
                                </div>

                                <h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Import</span></h4>
                                <form action="{{ url( 'admin/attribute/importmasterdata') }}"  method="POST" enctype="multipart/form-data" >          
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group">
                                            <input type="file" name="attribute_file" class="form-control" style="line-height: 19px;" />

                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <input type="hidden" value="{{ csrf_token()}}" name="_token"/>
                                        <button type="submit" class="btn btn-default "><i class="fa fa-upload"></i> Import</button>
                                    </div>
                                </div>
                                </form>         
                            </div>
                        </div>
                    </div>

@endsection
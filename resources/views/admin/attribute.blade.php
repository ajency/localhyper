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
							<select id="Department" class="select2-container select2 form-control select2-container-active">
                                                    <option value="">Select Department</option>
                                                    <option >Home Appliances</option>
                                                    <option >Kitchen Appliances</option>
                            </select>
						</div>
					</div>
					<div class="col-sm-4">
						<div class="form-group">
							<label class="form-label">Categories</label>
							<select id="categories" class="select2-container select2 form-control select2-container-active">
                                                    <option value="">Select Category</option>
                                                    <option >Home Appliances</option>
                                                    <option >Kitchen Appliances</option>
                                                </select>
						</div>
					</div>
					<div class="col-sm-4">
							<button type="button" class="btn btn-info btn-cons m-t-25"><i class="fa fa-send"></i> Go</button>
					</div>
				</div>
			
				<h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Export</span></h4>
				
					<button type="button" class="btn btn-default btn-cons btn-small"><i class="fa fa-download"></i> Download Sheet</button>
				
				<h4><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold">Import</span></h4>
				<div class="row">
					<div class="col-sm-4">
				<div class="form-group">
				<input type="file" class="form-control" style="line-height: 19px;"/>
					
				</div>
			</div>
			<div class="col-sm-4">
				<button type="button" class="btn btn-default "><i class="fa fa-upload"></i> Import</button>
			</div>
			</div>
			</div>
		</div>
    </div>
 

@endsection
@extends('app')

@section('content')
<div class="container">
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">Home</div>

				<div class="panel-body">
<!-- BEGIN PAGE TITLE -->
<div class="page-title">	
    <h2><span class="semi-bold">Add</span> Category</h2>
</div>
<!-- END PAGE TITLE -->
<!-- BEGIN PlACE PAGE CONTENT HERE -->
<div class="row">
    <div class="col-md-12">
        <div class="grid simple">
            <div class="grid-body no-border"> 
                <br>
                <form id="add_project" method="POST" action="admin/category" data-parsley-validate>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label class="form-label">Name<span class="text-primary">*</span></label>
                                <input type="text" name="name" class="form-control m-b-5" placeholder="Enter Category Name" data-parsley-required>
                                                           </div>
                        </div>
                       
                        </div>
                         <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label class="form-label">Parent<span class="text-primary">*</span></label>
<!--                                 <select name="user_role" class="select2 form-control m-b-5" data-parsley-required>
                                    <option value="">Select Parent Category</option>
                                    
                                    
                                   
                                </select> -->
                              <input type="text" name="name" class="form-control m-b-5" placeholder="Enter Parent Category" data-parsley-required>
                            </div>
                        </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label class="form-label">Sort ID<span class="text-primary">*</span></label>
                                    <input type="text" name="name" class="form-control m-b-5" placeholder="Sort Id" data-parsley-required>
                                    
                                </div>
                            </div>
                       </div>
                              

                    <div class="form-actions "> 
                        <div class="pull-right">
                            <input type="hidden" id="addanother" name="addanother" value="">
                            <input type="hidden" value="{{ csrf_token()}}" name="_token"/>
                            <button type="submit" class="btn btn-primary btn-cons"><i class="fa fa-plus-circle"></i> Create</button>
                            <button type="button" onclick="saveAndAddAnother();" class="btn btn-default btn-cons">Save And Create Another</button>
                            <button type="reset" class="hidden" />
                            <a href="{{ url('admin/user') }}"><button type="button" class="btn btn-default btn-cons"><i class="fa fa-ban"></i> Cancel</button></a>

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
	</div>
</div>
@endsection
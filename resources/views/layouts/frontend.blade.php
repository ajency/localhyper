<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
<meta charset="utf-8" />
<title>LocalHyper</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<meta content="" name="description" />
<meta content="" name="author" />
    
<!-- BEGIN PLUGIN CSS -->
<link href="{{ asset('plugins/pace/pace-theme-flash.css') }}" rel="stylesheet" type="text/css" media="screen"/>
<!-- END PLUGIN CSS -->
<!-- BEGIN CORE CSS FRAMEWORK -->
<link href="{{ asset('plugins/boostrapv3/css/bootstrap.min.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('plugins/boostrapv3/css/bootstrap-theme.min.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('plugins/font-awesome/css/font-awesome.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/animate.min.css') }}" rel="stylesheet" type="text/css"/>

<link href="{{ asset('plugins/jquery-scrollbar/jquery.scrollbar.css') }}" rel="stylesheet" type="text/css"/>
<!-- END CORE CSS FRAMEWORK -->
<!-- BEGIN CSS TEMPLATE -->
<link href="{{ asset('plugins/bootstrap-toggle/css/bootstrap-toggle.min.css') }}" rel="stylesheet" type="text/css" media="screen">
<link href="{{ asset('/plugins/select2/select2_metro.min.css') }}" rel="stylesheet" type="text/css" media="screen">
<link href="{{ asset('css/style.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/responsive.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/custom-icon-set.css') }}" rel="stylesheet" type="text/css"/>

<!-- END CSS TEMPLATE -->
<script src="{{ asset('plugins/jquery-1.8.3.min.js') }}" type="text/javascript"></script>  
</head>
<!-- END HEAD -->

<!-- BEGIN BODY -->
<body class="">
<!-- BEGIN HEADER -->
<!-- <div class="header navbar navbar-inverse "> 
  <!-- BEGIN TOP NAVIGATION BAR -->
 
  <!-- END TOP NAVIGATION BAR --> 
</div>
<!-- END HEADER -->
<!-- BEGIN CONTAINER -->
<div class="page-container row-fluid">
  <!-- BEGIN SIDEBAR -->

  <!-- BEGIN MINI-PROFILE -->
   
  
  <!-- END MINI-PROFILE -->
   
   <!-- BEGIN SIDEBAR MENU -->	

    <!-- END SIDEBAR MENU --> 

  
  <a href="#" class="scrollup">Scroll</a>
  
  <!-- END SIDEBAR --> 
  <!-- BEGIN PAGE CONTAINER-->
  <div class="faq page-content  no-sidebar"> 
    <!-- BEGIN SAMPLE PORTLET CONFIGURATION MODAL FORM-->
    <div id="portlet-config" class="modal hide">
      <div class="modal-header">
        <button data-dismiss="modal" class="close" type="button"></button>
        <h3>Widget Settings</h3>
      </div>
      <div class="modal-body"> Widget settings form goes here </div>
    </div>
    <div class="clearfix"></div>
      @yield('content')
  </div>

<!-- END CHAT --> 
 </div>



<!-- END CONTAINER --> 
<!-- Modal -->




<!-- END CONTAINER -->
<!-- BEGIN CORE JS FRAMEWORK--> 
<script src="{{ asset('plugins/boostrapv3/js/bootstrap.min.js') }}" type="text/javascript"></script> 
<script src="{{ asset('plugins/breakpoints.js') }}" type="text/javascript"></script> 
<script src="{{ asset('plugins/jquery-unveil/jquery.unveil.min.js') }}" type="text/javascript"></script> 
<script src="{{ asset('plugins/jquery-scrollbar/jquery.scrollbar.min.js') }}" type="text/javascript"></script> 
<script src="{{ asset('plugins/bootstrap-toggle/js/bootstrap-toggle.min.js') }}" type="text/javascript"></script>
<!-- END CORE JS FRAMEWORK --> 
<!-- BEGIN PAGE LEVEL JS --> 
 <script src="{{ asset('plugins/select2/select2.min.js') }}" type="text/javascript"></script>

<script src="{{ asset('plugins/pace/pace.min.js') }}" type="text/javascript"></script>  
<script src="{{ asset('plugins/jquery-numberAnimate/jquery.animateNumbers.js') }}" type="text/javascript"></script>
<!-- END PAGE LEVEL PLUGINS --> 
<script src="{{ asset('js/tabs_accordian.js') }}" type="text/javascript"></script>    

<script src="{{ asset('bower_components/underscore/underscore-min.js' ) }}" type="text/javascript"></script>    
    
    
<!-- BEGIN CORE TEMPLATE JS --> 
<script src="{{ asset('js/core.js') }}" type="text/javascript"></script> 
<script src="{{ asset('js/chat.js') }}" type="text/javascript"></script> 


<!-- END CORE TEMPLATE JS --> 

   
</body>
</html>
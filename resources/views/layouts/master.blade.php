<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
<meta charset="utf-8" />
<title>LocalHyper</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<meta content="" name="description" />
<meta content="" name="author" />
<meta name="csrf-token" content="{{ csrf_token() }}" />    
    
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
<link href="{{ asset('plugins/select2/select2_metro.min.css') }}" rel="stylesheet" type="text/css" media="screen">
<link href="{{ asset('css/style.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/responsive.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/custom-icon-set.css') }}" rel="stylesheet" type="text/css"/>
<script>
    var BASEURL = '{{ url() }}';
    var JAVASCRIPT_KEY = '{{ config("constants.parse_sdk.javascript_key") }}';
    var APPLICATION_ID = '{{ config("constants.parse_sdk.app_id") }}';
    var REST_API_KEY = '{{ config("constants.parse_sdk.rest_api_key") }}';

</script>
<script src="{{ asset('plugins/jquery-1.8.3.min.js') }}" type="text/javascript"></script>     
<!-- END CSS TEMPLATE -->

</head>
<!-- END HEAD -->

<!-- BEGIN BODY -->
<body class="">
<!-- BEGIN HEADER -->
<div class="header navbar navbar-inverse "> 
  <!-- BEGIN TOP NAVIGATION BAR -->
  <div class="navbar-inner">
	<div class="header-seperation"> 
		<ul class="nav pull-left notifcation-center" id="main-menu-toggle-wrapper" style="display:none">	
		 <li class="dropdown"> <a id="main-menu-toggle" href="#main-menu"  class="" > <div class="iconset top-menu-toggle-white"></div> </a> </li>		 
		</ul>
      <!-- BEGIN LOGO -->	
      <a href="index.html"><img src="assets/img/logo.png" class="logo" alt=""  data-src="assets/img/logo.png" data-src-retina="assets/img/logo2x.png" width="106" height="21"/></a>
      
      </div>
      <!-- END RESPONSIVE MENU TOGGLER --> 
      <div class="header-quick-nav" > 
      <!-- BEGIN TOP NAVIGATION MENU -->
	  <div class="pull-left"> 
        <ul class="nav quick-section">
          <li class="quicklinks"> <a href="#" class="" id="layout-condensed-toggle" >
            <div class="iconset top-menu-toggle-dark"></div>
            </a> </li>
        </ul>
       
	  </div>
	 <!-- END TOP NAVIGATION MENU -->
	 <!-- BEGIN CHAT TOGGLER -->
      <div class="pull-right"> 
		
		 <ul class="nav quick-section ">
			<li class="quicklinks"> 
				<a data-toggle="dropdown" class="dropdown-toggle  pull-right " href="#" id="user-options">						
					<div class="iconset top-settings-dark "></div> 	
				</a>
				<ul class="dropdown-menu  pull-right" role="menu" aria-labelledby="user-options">
                  <li><a href="#"><i class="fa fa-user"></i> My Account</a>
                  </li>
                  <li class="divider"></li>                
                  <li><a href="{{ url('/auth/logout') }}"><i class="fa fa-power-off"></i>&nbsp;&nbsp;Log Out</a></li>
               </ul>
			</li> 
			
		</ul>
      </div>
	   <!-- END CHAT TOGGLER -->
      </div> 
      <!-- END TOP NAVIGATION MENU --> 
   
  </div>
  <!-- END TOP NAVIGATION BAR --> 
</div>
<!-- END HEADER -->
<div class="page-container row-fluid">
  <!-- BEGIN SIDEBAR -->
  <div class="page-sidebar" id="main-menu"> 
  <!-- BEGIN MINI-PROFILE -->
   <div class="page-sidebar-wrapper scrollbar-dynamic" id="main-menu-wrapper"> 
   <div class="user-info-wrapper">	
	
    <div class="user-info">
      <div class="greeting">Welcome</div>
      <div class="username">{{ Auth::user()->name }}</div>
    </div>
   </div>
  <!-- END MINI-PROFILE -->
   
   <!-- BEGIN SIDEBAR MENU -->	
	<p class="menu-title">BROWSE <span class="pull-right"><a href="javascript:;"><i class="fa fa-refresh"></i></a></span></p>
    <ul>	
      <li class="start active "> <a href="{{ url('admin/attribute/categoryconfiguration') }}"> <i class="fa fa-sitemap"></i> <span class="title">Category Configuration</span> <span class="selected"></span></a> </li>
      <li class="start active "> <a href="{{ url('admin/customer') }}"> <i class="fa fa-sitemap"></i> <span class="title">Customers</span> <span class="selected"></span></a> </li>
      <li class="start active "> <a href="{{ url('admin/seller') }}"> <i class="fa fa-sitemap"></i> <span class="title">Sellers</span> <span class="selected"></span></a> </li>    
    </ul>
		
	<div class="clearfix"></div>
    <!-- END SIDEBAR MENU --> 
  </div>
  </div>
  <a href="#" class="scrollup">Scroll</a>
  
  <!-- END SIDEBAR --> 
  <!-- BEGIN PAGE CONTAINER-->
<div class="page-content"> 
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

<!-- END CHAT --> 
 </div>     
 </div>    
 
<script type="text/javascript" src="http://www.parsecdn.com/js/parse-1.4.2.min.js"></script> 
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
<script src="{{ asset('js/scripts.js') }}" type="text/javascript"></script>

<!-- END CORE TEMPLATE JS --> 
 
  <script type="text/javascript">
  Parse.initialize(window.APPLICATION_ID, window.JAVASCRIPT_KEY);
  </script>  
</body>
</html>

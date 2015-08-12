/*$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
});*/
var categorieData;

function getCategories()
{   
    $.ajax({
        async :true, 
        url: "https://api.parse.com/1/functions/getCategories",
        type: "POST",
        headers: {
                    "x-parse-application-id": window.APPLICATION_ID,
                    "x-parse-rest-api-key": window.REST_API_KEY
                  },
        data: {
            "sort_by": "popularity",
        },
        dataType: "JSON",
        success: function (response) {
          window.categorieData = response.result.data; 
            
          getDepartment();     
 
        }
    });
}

function getDepartment()
{   var temp= window.categorieData;
    var deparments = _.where(temp, {parent: null});

    $.each(deparments, function( index, items ) {
      str = '<option value="'+items.id+'">'+items.name+'</option>';    
      $('#department').append(str);
    });
    
}

function getChildCategory(obj) {
    var deparmentId =obj.value;  
    var temp= window.categorieData;
    var deparmentChildrens = _.where(temp, {id: deparmentId});
    var categoryData = deparmentChildrens[0].children;
    
    //Reset caregories
    $("select[name='category']").html('<option value="">Select Category</option>');
    $("select[name='category']").select2('val', '');
    $(".export_block").addClass('hidden');
    
    $.each(categoryData, function( index, items ) {
      str = '<option value="'+items.id+'">'+items.name+'</option>';    
      $("select[name='category']").append(str);
    });
    
}
/*function getChildCategory(obj) {
    var catId =obj.value;
    if(catId=='')
    {
        alert('Please Select Department');
        return;
    }
    $.ajax({
        url: "/admin/category/getchildcategories/"+catId,
        type: "POST",
        data: {
            catId: obj.value,
        },
        dataType: "JSON",
        success: function (response) {
            $("select[name='category']").html(response.data.html);
            $(".export_block").addClass('hidden');
 
        }
    });
}*/

$("select[name='category']").change(function(){
    $(".export_block").addClass('hidden');
});
    

function showAttibuteExport()
{
    var department = $("select[name='department']").val(); 
    var category = $("select[name='category']").val();
 
    var error = false;
    if(department =='')
    {
        alert('Please Select Department');
        error = true;
    }
    
    if(category=='')
    {
        alert('Please Select Category');
        error = true;
    }
 
    
    if(!error){
        var attributeUrl = BASEURL +'/admin/attribute/exportattributes/'+category;
        var productUrl = BASEURL +'/admin/product/exportproducts/'+category;
        var productPriceUrl = BASEURL +'/admin/product/exportproductonlineprice/'+category;
        $(".export_attributes").attr('href',attributeUrl);
        $(".export_product").attr('href',productUrl);
        $(".export_product_price").attr('href',productPriceUrl);
        
        $(".update-search-keyword").attr("data-category-id",category);
        $(".export_block").removeClass('hidden');
    
    }
    else
    {
        $(".export_attributes").attr('href','#');
        $(".export_product").attr('href','#');
    }
    
}

$(".update-search-keyword").click(function(){
     var categoryId = $(this).attr('data-category-id'); 
      $.ajax({
        async :true, 
        url: "#",
        type: "POST",
        headers: {
                    "x-parse-application-id": window.APPLICATION_ID,
                    "x-parse-rest-api-key": window.REST_API_KEY
                  },
        data: {
            "categoryId" : categoryId,
        },
        dataType: "JSON",
        success: function (response) {
            

        }
    }); 
});

$(".edit-balance-credit").click(function(){
     var str = '<input type="text" name="balanceCredit"><button class="save-seller-credits">save</button>';
     $(this).closest('td').find(".balance-credit").append(str);
     $(this).closest('td').find(".edit-balance-credit").addClass("hidden");
});

$('.sellerList').on('click', '.save-seller-credits', function () { 
    var balance = $(this).closest('td').find("input[name='balanceCredit']").val(); 
    var container = $(this).closest('td');
    var sellerid = container.find(".balance-credit").attr('data-seller-id'); 
    
    if(!isInteger(balance))
    {
        alert('Enter Valid Number')
        return;
    }
    
    $.ajax({
        async :true, 
        url: "https://api.parse.com/1/functions/addCredits",
        type: "POST",
        headers: {
                    "x-parse-application-id": window.APPLICATION_ID,
                    "x-parse-rest-api-key": window.REST_API_KEY
                  },
        data: {
            "sellerId" : sellerid,
            "newAddedCredits" : balance,   
        },
        dataType: "JSON",
        success: function (response) {
            var balanceCredits = parseInt(response.result.addedCredit)-parseInt(response.result.subtractedCredit)
            container.find(".balance-credit").html(balanceCredits);
            container.find(".edit-balance-credit").removeClass("hidden"); 

        }
    });
     
});

function isInteger(n) {
    return /^[0-9]+$/.test(n);
}


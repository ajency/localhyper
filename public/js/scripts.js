/*$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
});*/

$.notify.defaults({
      globalPosition: 'bottom right'
    });


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
        var productUrl = BASEURL +'/admin/product/exportproducts/'+category+'/true';
        var emptyProductUrl = BASEURL +'/admin/product/exportproducts/'+category;
        var productPriceUrl = BASEURL +'/admin/product/exportproductonlineprice/'+category;
        $(".export_attributes").attr('onclick',"location.href='"+attributeUrl+"'");
        $(".export_product").attr('onclick',"location.href='"+productUrl+"'");
        $(".export_empty_product").attr('onclick',"location.href='"+emptyProductUrl+"'");
        $(".export_product_price").attr('onclick',"location.href='"+productPriceUrl+"'");
        
        $(".update-search-keyword").attr("data-category-id",category);
        $(".export_block").removeClass('hidden');
    
    }
    else
    {
        $(".export_attributes").removeAttr('onclick');
        $(".export_product").removeAttr('onclick');
        $(".export_empty_product").removeAttr('onclick');
        $(".export_product_price").removeAttr('onclick');
    }
    
}

$(".update-search-keyword").click(function(){
     var categoryId = $(this).attr('data-category-id'); 
      $.ajax({
        async :true, 
        url: "https://api.parse.com/1/jobs/updateCategoryProductsKeywords",
        type: "POST",
        headers: {
                    "x-parse-application-id": window.APPLICATION_ID,
                    "x-parse-rest-api-key": window.REST_API_KEY,
                    "x-parse-master-key": window.MASTER_KEY,
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
     var str = '<input type="text" name="balanceCredit" class="input-sm" ><button class="cancel-seller-credits btn btn-xs btn-mini btn-default m-t-5 pull-right m-l-5">Cancel</button> <button class="save-seller-credits btn btn-xs btn-mini btn-info m-t-5 pull-right">Save</button> ';
     $(this).closest('td').find(".balance-credit").append(str);
     $(this).closest('td').find(".edit-balance-credit").addClass("hidden");
});


$('.sellerList').on('click', '.cancel-seller-credits', function () { 
    var container = $(this).closest('td');
    container.find("input[name='balanceCredit']").remove(); 
    container.find(".save-seller-credits").remove(); 
    container.find(".cancel-seller-credits").remove(); 
    container.find(".edit-balance-credit").removeClass("hidden"); 

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
            $.notify("Balance Credit Successfully Added", 'success');

        }
    });
     
});

function isInteger(n) {
    return /^[0-9]+$/.test(n);
}

$('.btn-import').click(function(){
    $(this).addClass("hidden");
});

function getCategoryProducts(pageNo)
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

    $(".loader").removeClass('hidden');
    
    if(!error){
      
        $.ajax({
        async :true, 
        url: "/admin/product/getproductprices/"+category,
        type: "GET",
        headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        },
        data: {
            "page" : pageNo,
 
        },
        dataType: "JSON",
        success: function (response) {
        var str ='';        
        var products = response.data.productLists;
        $.each(products, function (index, value) {
            var prices = value.product_prices;
            var amazonPrice = filpkartPrice = snapdealPrice = amazonPriceId = filpkartPriceId = snapdealPriceId = '';
            
            $.each(prices, function (index, value) {
                if(index=='amazon')
                {
                    amazonPrice = value['VALUE'];
                    amazonPriceId = value['ID'];
                }
                else if(index=='flipkart')
                {
                    filpkartPrice = value['VALUE'];
                    filpkartPriceId = value['ID'];
                }
                else if(index=='snapdeal')
                {
                    snapdealPrice = value['VALUE'];  
                    snapdealPriceId = value['ID'];
                }
            });
            /*var amazonePrice = (typeof(prices.amazone) != "undefined" && prices.amazone !== null) ? prices.amazone : '';
            var filpkartPrice =(typeof(prices.filpkart) != "undefined" && prices.filpkart !== null) ? prices.filpkart : '';
            var snapdealPrice =(typeof(snapdeal['VALUE']) != "undefined" && prices.snapdeal !== null) ? prices.snapdeal : '';*/
 
            str += '<tr>'; 
            str += '<td>'+value.name+'</td>'; 
            str += '<td>'+value.model_number+'</td>'; 
            str += '<td data-type="amazon" data-type-id="'+amazonPriceId+'" >'+amazonPrice+'</td>'; 
            str += '<td data-type="flipkart" data-type-id="'+filpkartPriceId+'">'+filpkartPrice+'</td>'; 
            str += '<td data-type="snapdeal" data-type-id="'+snapdealPriceId+'">'+snapdealPrice+'</td>'; 
            str += '<td data-product-id="'+value.id+'"> <a class="edit-product-price">edit</a> </td>'; 
            str += '</tr>'; 
        });
            
        $('.productPriceList').DataTable().destroy();     
        $(".productPriceList tbody").html(str);
        $(".productPriceList").dataTable({
            "sDom": "<'row'<'col-md-6'l><'col-md-6'f>r>t<'row'<'col-md-12'p i>>",
            "bPaginate": false,
            "bFilter": false,
            "bInfo":false,
            "aaSorting": [],
            "oLanguage": {
                "sLengthMenu": "_MENU_ ",
                "sInfo": "Showing <b>_START_ to _END_</b> of _TOTAL_ entries"
            },
            "aoColumnDefs": [
                { "sType": "date-uk", "aTargets": ["date-sort"] }
            ]
        });
        var pageNo = parseInt(response.data.page);    
        var prevPageLink = (pageNo >= 1) ? 'onclick="getCategoryProducts('+ (pageNo - 1) +');" ':'' ;
        var nextPageLink = (pageNo < response.data.numOfPages) ? 'onclick="getCategoryProducts('+ (pageNo + 1) +');" ' :'' ;  
        
        var pagination = '<a '+prevPageLink+' href="#"> previous </a> ';
        pagination += (pageNo + 1) +' of '+response.data.numOfPages ;
        pagination += '<a '+nextPageLink+' href="#"> next </a> ';  
  
        $("#pagination").html(pagination);
         
        $(".productPriceList").removeClass('hidden'); 
        $(".loader").addClass('hidden');   
        }
    }); 
        
    }
}

$('.productPriceList').on('click', '.edit-product-price', function () { 
    var amazonPrice = $(this).closest('tr').find('td[data-type="amazon"]');
    var filpkartPrice =$(this).closest('tr').find('td[data-type="flipkart"]');
    var snapdealPrice =$(this).closest('tr').find('td[data-type="snapdeal"]');
    
    amazonPrice.html('<input type="text" name="amazon_price" value="'+amazonPrice.text()+'">');
    filpkartPrice.html('<input type="text" name="flipkar_price" value="'+filpkartPrice.text()+'">');
    snapdealPrice.html('<input type="text" name="snadeal_price" value="'+snapdealPrice.text()+'">');
    
    $(this).addClass('hidden');
    $(this).closest('td').append('<input type="button" class="save-product-price  btn btn-xs btn-mini btn-info m-t-5 pull-right" value="save">');
    
    
});

$('.productPriceList').on('click', '.save-product-price', function () { 
    
    var obj = $(this);
    
    var productId = $(this).closest('td').attr('data-product-id');
    var amazonPrice = $(this).closest('tr').find('td[data-type="amazon"]');
    var filpkartPrice =$(this).closest('tr').find('td[data-type="flipkart"]');
    var snapdealPrice =$(this).closest('tr').find('td[data-type="snapdeal"]');
    
    var amazonPriceValue =amazonPrice.find('input').val();
    var amazonPriceId = amazonPrice.attr('data-type-id'); 
    var filpkartPriceValue =filpkartPrice.find('input').val();
    var filpkartPriceId = filpkartPrice.attr('data-type-id');
    var snapdealPriceValue =snapdealPrice.find('input').val();
    var snapdealPriceId = snapdealPrice.attr('data-type-id');
    
   
    
    $.ajax({
        async :true, 
        url: "/admin/product/"+productId+"/productonlineprice",
        type: "POST",
        headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
        },
        data: {
            "amazonPrice" : amazonPriceValue,
            "amazonPriceId" : amazonPriceId,
            "filpkartPrice" : filpkartPriceValue,
            "filpkartPriceId" : filpkartPriceId,
            "snapdealPrice" : snapdealPriceValue,
            "snapdealPriceId" : snapdealPriceId,
        },
        dataType: "JSON",
        success: function (response) { 
            
            amazonPrice.attr('data-type-id',response.data.amazonPriceId); 
            filpkartPrice.attr('data-type-id',response.data.filpkartPriceId); 
            snapdealPrice.attr('data-type-id',response.data.snapdealPriceId); 
            
            amazonPrice.html(amazonPriceValue);
            filpkartPrice.html(filpkartPriceValue);
            snapdealPrice.html(snapdealPriceValue);
            
            
            obj.closest('td').find('.edit-product-price').removeClass('hidden');
            obj.remove();
            $.notify("Price Successfully Updated", 'success');
     
        }
    }); 
     
    
     
    
    
    
});





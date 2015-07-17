Parse.Cloud.define "sendMail", (request, status) ->
	productName = request.params.productName
	category = request.params.category
	brand = request.params.brand
	description = request.params.description
	comments = request.params.comments


	text = '<p>Product Name:'+productName+'<br> Category:' + category + '<br> Brand: ' + brand + '<br> Categories: ' + description + '<br> Comments:' + comments+'<p>'

	
	Mandrill = require('mandrill');
	Mandrill.initialize('JGQ1FMECVDSJLnOFvxDzaQ')
	
	
	
	Mandrill.sendEmail({message:{
		html: "<p>"+text+"</p>",
		text: text,
		subject: "Product suggestions",
		from_email: "parse@cloudcode.com",
		from_name: "Cloud Code",
		to: [{ email: "namrata@ajency.in", name: "Your Name"}]

		},async: true
		},{
			success: (httpResponse) ->
				console.log(httpResponse)
				status.success 'Mail Sent'

			error: (httpResponse) ->
				console.error(httpResponse)
				status.error 'err'
		})


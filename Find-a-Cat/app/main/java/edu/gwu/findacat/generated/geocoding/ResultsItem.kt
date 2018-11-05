package edu.gwu.findacat.generated.geocoding

import com.squareup.moshi.Json

data class ResultsItem(

	@Json(name="formatted_address")
	val formattedAddress: String,

	@Json(name="address_components")
	val addressComponents: List<AddressComponentsItem>


)
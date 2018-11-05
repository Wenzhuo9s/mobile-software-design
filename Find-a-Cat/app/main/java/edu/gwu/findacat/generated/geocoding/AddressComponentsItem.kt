package edu.gwu.findacat.generated.geocoding

import com.squareup.moshi.Json

data class AddressComponentsItem(

	@Json(name="types")
	val types: List<String>,

	@Json(name="short_name")
	val shortName: String,

	@Json(name="long_name")
	val longName: String
)
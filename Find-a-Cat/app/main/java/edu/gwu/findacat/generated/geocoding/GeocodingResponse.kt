package edu.gwu.findacat.generated.geocoding


import com.squareup.moshi.Json


data class GeocodingResponse(

	@Json(name="results")
	val results: List<ResultsItem>
)
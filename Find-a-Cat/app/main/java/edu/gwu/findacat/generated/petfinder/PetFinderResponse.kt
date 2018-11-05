package edu.gwu.findacat.generated.petfinder

import android.os.Parcelable
import com.squareup.moshi.Json
import edu.gwu.findacat.generated.petfinder.Petfinder
import kotlinx.android.parcel.Parcelize

@Parcelize
data class PetFinderResponse(
	@Json(name="petfinder")
	val petfinder: Petfinder
): Parcelable
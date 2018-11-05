package edu.gwu.findacat.generated.petfinder

import android.os.Parcelable
import com.squareup.moshi.Json
import kotlinx.android.parcel.Parcelize

@Parcelize
data class Contact(
	@Json(name = "email") val email: StringWrapper,
	@Json(name = "zip") val zip: StringWrapper
): Parcelable
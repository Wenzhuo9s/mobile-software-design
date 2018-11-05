package edu.gwu.findacat.generated.petfinder


import android.os.Parcelable
import com.squareup.moshi.Json
import kotlinx.android.parcel.Parcelize

@Parcelize
data class Media(@Json(name = "photos") val photos: Photos?): Parcelable
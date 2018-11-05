package edu.gwu.findacat.generated.petfinder

import android.os.Parcelable
import com.squareup.moshi.Json
import edu.gwu.findacat.generated.petfinder.PhotoItem
import kotlinx.android.parcel.Parcelize

@Parcelize
data class Photos(@Json(name = "photo") val photo: List<PhotoItem>):Parcelable
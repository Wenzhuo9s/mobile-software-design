package edu.gwu.findacat.generated.petfinder


import android.os.Parcelable
import com.squareup.moshi.Json
import kotlinx.android.parcel.Parcelize

@Parcelize
data class PetItem(
    @Json(name = "contact") val contact: Contact,
    @Json(name = "media") val media: Media,
    @Json(name = "id") val id: StringWrapper,
    @Json(name = "breeds") val breeds: Breeds,
    @Json(name = "name") val name: StringWrapper,
    @Json(name = "sex") val sex: StringWrapper,
    @Json(name = "description") val description: StringWrapper,
    @Json(name = "favorite") var favorite: Boolean = false
):Parcelable
package edu.gwu.findacat.generated.petfinder


import android.os.Parcelable
import com.squareup.moshi.Json
import edu.gwu.findacat.generated.petfinder.PetItem
import kotlinx.android.parcel.Parcelize

@Parcelize
data class Pets(

	@Json(name="pet")
	val pet: List<PetItem>
): Parcelable